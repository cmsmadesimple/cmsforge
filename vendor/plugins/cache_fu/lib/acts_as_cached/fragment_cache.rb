module ActsAsCached
  module FragmentCache
    def self.setup!
      class << CACHE
        include Extensions
      end
      
      setup_rails_for_memcache_fragments
      setup_rails_for_action_cache_options
    end
    
    # add :ttl option to cache helper and set cache store memcache object
    def self.setup_rails_for_memcache_fragments
      ::ActionView::Helpers::CacheHelper.class_eval do
        def cache(name = {}, options = nil, &block)
          @controller.cache_erb_fragment(block, name, options)
        end
      end
      ::ActionController::Base.fragment_cache_store = CACHE
    end
    
    # add :ttl option to caches_action on the per action level by passing in a hash instead of an array
    # 
    # Examples:
    #  caches_action :index                                       # will use the default ttl from your memcache.yml, or 25 minutes
    #  caches_action :index => { :ttl => 5.minutes }              # cache index action with 5 minute ttl
    #  caches_action :page, :feed, :index => { :ttl => 2.hours }  # cache index action with 2 hours ttl, all others use default
    #
    def self.setup_rails_for_action_cache_options
      ::ActionController::Caching::Actions::ActionCacheFilter.class_eval do
        # convert all actions into a hash keyed by action named, with a value of a ttl hash (to match other cache APIs)
        def initialize(*actions, &block)
          @actions = actions.inject({}) do |hsh, action|
            returning(hsh) do
              action.is_a?(Hash) ? hsh.update(action) : hsh[action] = { :ttl => nil }
            end
          end
        end
        
        # override to pass along the ttl hash
        def after(controller)
          return if !@actions.include?(controller.action_name.intern) || controller.rendered_action_cache
          controller.write_fragment(ActionController::Caching::Actions::ActionCachePath.path_for(controller), controller.response.body, action_ttl(controller))
        end

        private
        def action_ttl(controller)
          @actions[controller.action_name.intern]
        end
      end
    end

    module Extensions
      def read(*args) ActsAsCached.config[:store].get(args.first) end
      def write(name, content, options = {}) 
        ttl = (options.is_a?(Hash) ? options[:ttl] : nil) || ActsAsCached.config[:ttl] || 25.minutes
        ActsAsCached.config[:store].set(name, content, ttl) 
      end
    end

    module DisabledExtensions
      def read(*args) nil end
      def write(*args) "" end
    end
  end
end
