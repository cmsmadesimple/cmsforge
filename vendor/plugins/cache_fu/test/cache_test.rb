require File.join(File.dirname(__FILE__), 'helper')

context "A Ruby class acting as cached (in general)" do
  include StoryCacheSpecSetup

  specify "should be able to retrieve a cached instance from the cache" do
    Story.get_cache(1).should.equal Story.find(1)
  end

  specify "should set to the cache if its not already set when getting" do
    Story.cached?(1).should.equal false
    Story.get_cache(1).should.equal Story.find(1)
    Story.cached?(1).should.equal true
  end

  specify "should not set to the cache if is already set when getting" do
    Story.expects(:set_cache).never
    Story.cached?(2).should.equal true
    Story.get_cache(2).should.equal Story.find(2)
    Story.cached?(2).should.equal true
  end

  specify "should be able to tell if a key is cached" do
    Story.is_cached?(1).should.equal false
    Story.cached?(1).should.equal false
    Story.cached?(2).should.equal true
  end

  specify "should be able to cache arbitrary methods using #cached" do
    Story.cache_store.expects(:get).returns(nil)
    Story.cache_store.expects(:set).with('Story:something_cool', :redbull, 1500)
    Story.cached(:something_cool).should.equal :redbull

    Story.cache_store.expects(:get).returns(:redbull)
    Story.cache_store.expects(:set).never
    Story.cached(:something_cool).should.equal :redbull
  end

  specify "should set false when trying to set nil" do
    Story.set_cache(3, nil).should.equal false
    Story.get_cache(3).should.equal false
  end

  specify "should be able to expire a cache key" do
    Story.cached?(2).should.equal true
    Story.expire_cache(2).should.equal true
    Story.cached?(2).should.equal false
  end

  specify "should return a boolean when trying to expire the cache" do
    Story.cached?(1).should.equal false
    Story.expire_cache(1).should.equal false
    Story.cached?(2).should.equal true
    Story.expire_cache(2).should.equal true
  end

  specify "should be able to reset a cache key, returning the cached object if successful" do
    Story.expects(:find).with(2).returns(@story2)
    Story.cached?(2).should.equal true
    Story.reset_cache(2).should.equal @story2
    Story.cached?(2).should.equal true
  end

  specify "should be able to cache the value of a block" do
    Story.cached?(:block).should.equal false
    Story.get_cache(:block) { "this is a block" }
    Story.cached?(:block).should.equal true
    Story.get_cache(:block).should.equal "this is a block"
  end

  specify "should be able to define a class level ttl" do
    ttl = 1124
    Story.cache_config[:ttl] = ttl
    Story.cache_config[:store].expects(:set).with(Story.cache_key(1), @story, ttl)
    Story.get_cache(1)
  end

  specify "should be able to define a per-key ttl" do
    ttl = 3262
    Story.cache_config[:store].expects(:set).with(Story.cache_key(1), @story, ttl)
    Story.get_cache(1, :ttl => ttl)
  end

  specify "should be able to skip cache gets" do
    Story.cached?(2).should.equal true
    ActsAsCached.skip_cache_gets = true
    Story.expects(:find).at_least_once
    Story.get_cache(2)
    ActsAsCached.skip_cache_gets = false
  end

  specify "should be able to use an arbitrary finder method via :finder" do
    Story.expire_cache(4)
    Story.cache_config[:finder] = :find_live
    Story.expects(:find_live).with(4).returns(false)
    Story.get_cache(4)
  end

  specify "should raise an exception if no finder method is found" do
    Story.cache_config[:finder] = :find_penguins
    proc { Story.get_cache(1) }.should.raise(ActsAsCached::NoCacheFinder)
  end

  specify "should modify its cache key to reflect a :version option" do
    Story.cache_config[:version] = 'new' 
    Story.cache_key(1).should.equal 'Story:new:1'
  end
  
  specify "should truncate the key normally if we dont have a namespace" do
    Story.stubs(:cache_namespace).returns(nil)
    key = "a" * 260
    Story.cache_key(key).length.should == 250
  end
  
  specify "should truncate key with length over 250, including namespace if set" do
    Story.stubs(:cache_namespace).returns("37-power-moves-app" )
    key = "a" * 260
    (Story.cache_namespace + Story.cache_key(key)).length.should == (250 - 1)
  end

  specify "should raise an informative error message when trying to set_cache with a proc" do
    Story.cache_config[:store].expects(:set).raises(TypeError.new("Can't marshal Proc"))
    proc { Story.set_cache('proc:d', proc { nil }) }.should.raise(ActsAsCached::MarshalError)
  end
end

context "Passing an array of ids to get_cache" do
  include StoryCacheSpecSetup

  setup do
    @grab_stories = proc do 
      @stories = Story.get_cache(1, 2, 3)
    end 

    # TODO: doh, probably need to clean this up...
    @cache = $with_memcache ? CACHE : $cache
  end

  specify "should try to fetch those ids using get_multi" do
    @cache.expects(:get_multi).with('Story:1', 'Story:2', 'Story:3').returns('Story:2' => $stories[2])
    @grab_stories.call
    @stories.size.should.equal 3
    @stories.should.be.an.instance_of Hash
    @stories.each { |id, story| story.should.be.an.instance_of Story }
  end

  specify "should pass the cache miss ids to #find" do
    Story.expects(:find).with(%w(1 3)).returns($stories[1], $stories[3])
    @grab_stories.call
  end

  specify "should raise an exception if get_multi is not supported" do
    class << @cache; undef :get_multi end
    proc { @grab_stories.call }.should.raise(ActsAsCached::NoGetMulti)
  end
end

context "A Ruby object acting as cached" do
  include StoryCacheSpecSetup

  specify "should be able to retrieve a cached version of itself" do
    Story.expects(:get_cache).with(1).at_least_once
    @story.get_cache
  end

  specify "should be able to set itself to the cache" do
    Story.expects(:set_cache).with(1, @story, nil).at_least_once
    @story.set_cache
  end

  specify "should pass its cached self into a block when supplied" do
    @story.get_cache { |object| object.should.equal @story }
  end

  specify "should be able to expire its cache" do
    Story.expects(:expire_cache).with(2)
    @story2.expire_cache
  end

  specify "should be able to reset its cache" do
    Story.expects(:reset_cache).with(2)
    @story2.reset_cache
  end

  specify "should be able to tell if it is cached" do
    @story.should.not.be.cached
    @story2.should.be.cached
  end

  specify "should be able to set itself to the cache with an arbitrary ttl" do
    ttl = 1500
    Story.expects(:set_cache).with(1, @story, ttl)
    @story.set_cache(ttl)
  end
end
