require File.join(File.dirname(__FILE__), 'helper')

context "The global cache configuration" do
  # Pass in a hash to update the config.
  # If the first arg is a symbol, an expectation will be set.
  def setup_config(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    @config[RAILS_ENV].update options.stringify_keys
    ActsAsCached::Config.expects(args.first) if args.first.is_a? Symbol
    ActsAsCached.config = @config
  end

  setup do
    ActsAsCached.config.clear
    @config = YAML.load_file('defaults/memcached.yml.default')
    @config['test'] = @config['development'].merge('benchmarking' => false, 'disabled' => false)
  end

  specify "should be able to set itself as the session store" do
    setup_config :setup_session_store, :sessions => true
  end

  specify "should be able to set itself as the fragment store" do
    setup_config :setup_fragment_store!, :fragments => true
  end

  specify "should construct a namespace from the environment and a config value" do
    setup_config
    ActsAsCached.config[:namespace].should.equal "app-#{RAILS_ENV}"
  end

  specify "should be able to set a global default ttl" do
    setup_config
    ActsAsCached.config[:ttl].should.not.be.nil
  end

  specify "should be able to swallow errors" do
    setup_config :raise_errors => false
    Story.send :acts_as_cached
    Story.stubs(:find).returns(Story.new)
    Story.cache_config[:store].expects(:get).raises(MemCache::MemCacheError)
    Story.cache_config[:store].expects(:set).returns(true)
    proc { Story.get_cache(1) }.should.not.raise(MemCache::MemCacheError)
  end

  specify "should not swallow marshal errors" do
    setup_config :raise_errors => false
    Story.send :acts_as_cached
    Story.stubs(:find).returns(Story.new)
    Story.cache_config[:store].expects(:get).returns(nil)
    Story.cache_config[:store].expects(:set).raises(TypeError.new("Some kind of Proc error"))
    proc { Story.get_cache(1) }.should.raise(ActsAsCached::MarshalError)
  end

  specify "should be able to re-raise errors" do
    setup_config :raise_errors => true
    Story.send :acts_as_cached
    Story.cache_config[:store].expects(:get).raises(MemCache::MemCacheError)
    proc { Story.get_cache(1) }.should.raise(MemCache::MemCacheError)
  end

  specify "should be able to enable benchmarking" do
    setup_config :benchmarking => true
    ActsAsCached.config[:benchmarking].should.equal true
    Story.send :acts_as_cached
    Story.methods.should.include 'fetch_cache_with_benchmarking'
  end

  specify "should be able to disable all caching" do
    setup_config :disabled => true
    Story.send :acts_as_cached
    Story.should.respond_to :fetch_cache_with_disabled
    ActsAsCached.config[:disabled].should.equal true
  end

  specify "should be able to use a global store other than memcache" do
    setup_config :store => 'HashStore'
    ActsAsCached.config[:store].should.equal HashStore.new
    Story.send :acts_as_cached
    Story.cache_config[:store].should.be ActsAsCached.config[:store]
  end

  specify "should be able to override the memcache-client hashing algorithm" do
    setup_config :fast_hash => true
    ActsAsCached.config[:fast_hash].should.equal true
    CACHE.hash_for('eatingsnotcheating').should.equal 1919
  end

  specify "should be able to override the memcache-client hashing algorithm" do
    setup_config :fastest_hash => true
    ActsAsCached.config[:fastest_hash].should.equal true
    CACHE.hash_for(string = 'eatingsnotcheating').should.equal string.hash
  end
end
