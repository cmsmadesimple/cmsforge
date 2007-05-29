module ActsAsCached
  module ClassMethods
    def cache_config
      config = ActsAsCached::Config.class_config[cache_name] ||= {}
      if name == cache_name
        config
      else
        # sti
        ActsAsCached::Config.class_config[name] ||= config.dup
      end
    end

    def cache_options
      cache_config[:options] ||= {}
    end

    def get_cache(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      args    = args.flatten

      ##
      # head off to get_caches if we were passed multiple ids
      if args.size > 1 
        return get_caches(args, options) 
      else
        id = args.first
      end

      if (item = fetch_cache(id)).nil?
        set_cache(id, block_given? ? yield : fetch_cachable_data(id), options[:ttl])
      else
        item
      end
    end

    ##
    # This method accepts an array of ids which it will use to call #get_multi on 
    # your cache store.  Any misses will be fetched and saved to the cache, and a
    # hash keyed by id will ultimately be returned.
    #
    # If your cache store does not support #get_multi an exception will be raised.
    def get_caches(*args)
      raise NoGetMulti unless cache_store.respond_to? :get_multi

      options = args.last.is_a?(Hash) ? args.pop : {}
      ids     = args.flatten.map(&:to_s)
      keys    = cache_keys(ids)

      # Map memcache keys to object ids in { memcache_key => object_id } format
      keys_map = Hash[*keys.zip(ids).flatten]

      # Call get_multi and figure out which keys were missed based on what was a hit
      hits   = cache_store(:get_multi, *keys) || {}
      misses = keys - hits.keys

      # Return our hash if there are no misses
      return hits.values.index_by(&:id) if misses.empty?

      # Find any missed records
      needed_ids     = keys_map.values_at(*misses)
      missed_records = Array(fetch_cachable_data(needed_ids))

      # Cache the missed records
      missed_records.each { |missed_record| missed_record.set_cache(options[:ttl]) }

      # Return all records as a hash indexed by object id
      (hits.values + missed_records).index_by(&:id)
    end

    def set_cache(id, value, ttl = nil)
      returning(value || false) do |v|
        cache_store(:set, cache_key(id), v, ttl || cache_config[:ttl] || 1500)
      end
    end

    def expire_cache(id = nil)
      return false unless cached? id
      !!cache_config[:store].delete(cache_key(id))
    end
    alias :clear_cache :expire_cache

    def reset_cache(id = nil)
      set_cache(id, fetch_cachable_data(id))
    end


    ##
    # Encapsulates the pattern of writing custom cache methods
    # which do nothing but wrap custom finders.
    #
    #   => Story.cached(:find_popular)
    #
    #   is the same as
    #
    #   def self.cached_find_popular
    #     get_cache(:find_popular) { find_popular }
    #   end
    def cached(method, options = {})
      get_cache(method, options) { send(method) }
    end

    def cached?(id = nil)
      fetch_cache(id).nil? ? false : true
    end
    alias :is_cached? :cached?

    def fetch_cache(id)
      return if ActsAsCached.config[:skip_gets]

      autoload_missing_constants do 
        cache_store(:get, cache_key(id))
      end
    end

    def fetch_cachable_data(id = nil)
      raise NoCacheFinder unless respond_to?(finder = cache_config[:finder] || :find)

      return send(finder) unless id

      args = [id]
      args << cache_options.dup unless cache_options.blank?
      send(finder, *args)
    end
    
    def cache_namespace
      cache_store(:namespace)
    end
    
    # Memcache-client automatically prepends the namespace, plus a colon, onto keys, so we take that into account for the max key length.
    # Rob Sanheim
    def max_key_length
      key_size = cache_config[:key_size] || 250
      @max_key_length ||= cache_namespace ? (key_size - cache_namespace.length - 1) : key_size
    end

    def cache_name
      @cache_name ||= respond_to?(:base_class) ? base_class.name : name
    end

    def cache_keys(*ids)
      ids.flatten.map { |id| cache_key(id) }
    end

    def cache_key(id)
      [cache_name, cache_config[:version], id].compact.join(':').gsub(' ', '_').first(max_key_length)
    end

    def cache_store(method = nil, *args)
      return cache_config[:store] unless method

      swallow_or_raise_cache_errors(method == :get) do
        cache_config[:store].send(method, *args)
      end
    end

    def swallow_or_raise_cache_errors(autoload = false, &block)
      autoload ? autoload_missing_constants(&block) : yield
    rescue ArgumentError, MemCache::MemCacheError => error
      if ActsAsCached.config[:raise_errors]
        raise error
      else
        ActiveRecord::Base.logger.debug "MemCache Error: #{error.message}" rescue nil
        nil
      end
    rescue TypeError => error
      if error.to_s.include? 'Proc' 
        raise MarshalError, "Most likely an association callback defined with a Proc is triggered, see http://ar.rubyonrails.com/classes/ActiveRecord/Associations/ClassMethods.html (Association Callbacks) for details on converting this to a method based callback" 
      else
        raise error
      end
    end

    def autoload_missing_constants
      yield
    rescue ArgumentError, MemCache::MemCacheError => error
      lazy_load ||= Hash.new { |hash, hash_key| hash[hash_key] = true; false }
      if error.to_s[/undefined class|referred/] && !lazy_load[error.to_s.split.last.constantize] then retry
      else raise error end
    end
  end

  module InstanceMethods
    def self.included(base)
      base.send :delegate, :cache_config,  :to => 'self.class'
      base.send :delegate, :cache_options, :to => 'self.class'
    end

    def get_cache
      cached = self.class.get_cache(id)
      block_given? ? yield(cached) : cached
    end

    def set_cache(ttl = nil)
      self.class.set_cache(id, self, ttl)
    end

    def reset_cache
      self.class.reset_cache(id)
    end

    def expire_cache
      self.class.expire_cache(id)
    end
    alias :clear_cache :expire_cache

    def cached?
      self.class.cached? id
    end

    def cache_key
      self.class.cache_key(id)
    end

    # Ryan King
    def set_cache_with_associations
      cache_options[:include].each do |assoc|
        send(assoc).reload
      end if cache_options[:include]
      set_cache
    end

    # Lourens Naudé
    def expire_cache_with_associations(*associations_to_sweep)
      ((cache_options[:include] || []) + associations_to_sweep).flatten.uniq.compact.each do |assoc|
        Array(send(assoc)).compact.each { |item| item.expire_cache if item.respond_to?(:expire_cache) }
      end 
      expire_cache
    end
  end
  
  class MarshalError < StandardError; end
end
