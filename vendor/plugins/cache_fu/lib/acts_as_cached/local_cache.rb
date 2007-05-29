module ActsAsCached
  module LocalCache
    @@local_cache = {}
    mattr_accessor :local_cache

    def fetch_cache_with_local_cache(*args)
      @@local_cache[cache_key(args.first)] ||= fetch_cache_without_local_cache(*args)
    end

    def set_cache_with_local_cache(*args)
      @@local_cache[cache_key(args.first)] = set_cache_without_local_cache(*args)
    end

    def expire_cache_with_local_cache(*args)
      @@local_cache[cache_key(args.first)] = nil if @@local_cache[cache_key(args.first)]
      expire_cache_without_local_cache(*args)
    end
    
    def cached_with_local_cache?(*args)
      !!@@local_cache[cache_key(args.first)] || cached_without_local_cache?(*args)
    end

    def self.add_to(klass)
      return if klass.ancestors.include? self
      klass.send :include, self

      klass.class_eval do
        alias_method_chain :fetch_cache,  :local_cache
        alias_method_chain :set_cache,    :local_cache
        alias_method_chain :expire_cache, :local_cache
        alias_method_chain :cached?,      :local_cache
      end
    end
  end
end

module ActionController
  class Base
    def local_cache_for_request
      ActsAsCached::LocalCache.add_to ActsAsCached::ClassMethods 
      ActsAsCached::LocalCache.local_cache = {}
    end
  end
end 
