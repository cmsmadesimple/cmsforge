require File.join(File.dirname(__FILE__), 'helper')
require 'test/unit'
require 'action_controller/test_process'

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end

class FooController < ActionController::Base
  def url_for(*args)
    "http://#{Time.now.to_i}.foo.com"
  end
end

class BarController < ActionController::Base
  def page
    render :text => "give me my bongos"
  end
  
  def index
    render :text => "doop!"
  end

  def rescue_action(e)
    raise e
  end
end

class FooTemplate
  include ::ActionView::Helpers::CacheHelper
  
  attr_reader :controller

  def initialize
    @controller = FooController.new
  end
end

context "Fragment caching (when used with memcached)" do
  include FragmentCacheSpecSetup
  
  setup do
    @view = FooTemplate.new
  end
  
  specify "should be able to cache with a normal, non-keyed Rails cache calls" do
    _erbout = ""
    content = "Caching is fun!"

    ActsAsCached.config[:store].expects(:set).with(@view.controller.url_for.gsub('http://',''), content, ActsAsCached.config[:ttl])

    @view.cache { _erbout << content }
  end
  
  specify "should be able to cache with a normal cache call when we don't have a default ttl" do
    begin
      _erbout = ""
      content = "Caching is fun!"
    
      original_ttl = ActsAsCached.config.delete(:ttl)
      ActsAsCached.config[:store].expects(:set).with(@view.controller.url_for.gsub('http://',''), content, 25.minutes)

      @view.cache { _erbout << content }
    ensure
      ActsAsCached.config[:ttl] = original_ttl
    end
  end

  specify "should be able to cache with a normal, keyed Rails cache calls" do
    _erbout = ""
    content = "Wow, even a key?!"
    key = "#{Time.now.to_i}_wow_key"

    ActsAsCached.config[:store].expects(:set).with(key, content, ActsAsCached.config[:ttl])

    @view.cache(key) { _erbout << content } 
  end
  
  specify "should be able to cache with new time-to-live option" do 
    _erbout = ""
    content = "Time to live?  TIME TO DIE!!"
    key = "#{Time.now.to_i}_death_key"

    ActsAsCached.config[:store].expects(:set).with(key, content, 60)
    @view.cache(key, { :ttl => 60 }) { _erbout << content }
  end

  specify "should ignore everything but time-to-live when options are present" do 
    _erbout = ""
    content = "Don't mess around, here, sir."
    key = "#{Time.now.to_i}_mess_key"

    ActsAsCached.config[:store].expects(:set).with(key, content, 60)
    @view.cache(key, { :other_options => "for the kids", :ttl => 60 }) { _erbout << content } 
  end
end

context "Action caching (when used with memcached)" do
  include FragmentCacheSpecSetup
  page_content = "give me my bongos"
  index_content = "doop!"
  
  setup do
    @controller = BarController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  teardown do # clear the filter chain between specs to avoid chaos
    BarController.write_inheritable_attribute('filter_chain', [])
  end
  
  # little helper for prettier expections on the cache
  def cache_expects(method, expected_times = 1)
    ActsAsCached.config[:store].expects(method).times(expected_times)
  end

  specify "should cache using default ttl for a normal action cache without ttl" do
    BarController.caches_action :page

    key = 'test.host/bar/page'
    cache_expects(:set).with(key, page_content, ActsAsCached.config[:ttl])
    get :page
    @response.body.should == page_content
    
    cache_expects(:read).with(key, nil).returns(page_content)
    get :page
    @response.body.should == page_content
  end
  
  specify "should cache using defaul ttl for normal, multiple action caches" do
    BarController.caches_action :page, :index
    
    cache_expects(:set).with('test.host/bar/page', page_content, ActsAsCached.config[:ttl])
    get :page
    cache_expects(:set).with('test.host/bar', index_content, ActsAsCached.config[:ttl])
    get :index
  end
  
  specify "should be able to action cache with ttl" do
    BarController.caches_action :page => { :ttl => 2.minutes }

    cache_expects(:set).with('test.host/bar/page', page_content, 2.minutes)
    get :page
    @response.body.should == page_content
  end
  
  specify "should be able to action cache multiple actions with ttls" do
    BarController.caches_action :index, :page => { :ttl => 5.minutes }
    
    cache_expects(:set).with('test.host/bar/page', page_content, 5.minutes)
    cache_expects(:set).with('test.host/bar', index_content, ActsAsCached.config[:ttl])
    
    get :page
    @response.body.should == page_content

    get :index
    @response.body.should == index_content
    cache_expects(:read).with('test.host/bar', nil).returns(index_content)

    get :index
  end
end
