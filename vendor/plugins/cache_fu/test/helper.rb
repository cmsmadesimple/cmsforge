##
# This file exists to fake out all the Railsisms we use so we can run the 
# tests in isolation.
$LOAD_PATH.unshift 'lib/'

# prepend vendor rails to the load path if it exists
VENDOR_RAILS_ROOT = File.dirname(__FILE__) + "/../../../../vendor/rails"
if File.directory?(VENDOR_RAILS_ROOT) 
  $LOAD_PATH.unshift "#{VENDOR_RAILS_ROOT}/activesupport/lib", "#{VENDOR_RAILS_ROOT}/actionpack/lib"
end

begin
  require 'rubygems'
  require 'mocha'
  require 'test/spec'
  require 'active_support'
  require 'action_controller'
  require 'action_view'
  gem 'test-spec', '= 0.3.0'
  gem 'mocha', '= 0.4.0'
rescue LoadError
  puts '=> acts_as_cached tests depend on the following gems: mocha, test-spec, active_support, action_controller, and action_view.'
end

begin
  require 'redgreen'
rescue LoadError
  nil
end

##
# real men test without mocks
if $with_memcache = ARGV.include?('with-memcache')
  require 'memcache'
end

##
# init.rb hacks
RAILS_ROOT = '.'    unless defined? RAILS_ROOT
RAILS_ENV  = 'test' unless defined? RAILS_ENV

##
# aac
require 'acts_as_cached'
Object.send :include, ActsAsCached::Mixin

##
# i need you.
module Enumerable
  def index_by
    inject({}) do |accum, elem|
      accum[yield(elem)] = elem
      accum
    end
  end
end

##
# mocky.
class HashStore < Hash
  alias :get :[]

  def get_multi(*values)
    reject { |k,v| !values.include? k }
  end

  def set(key, value, *others)
    self[key] = value
  end
  
  def namespace
    nil
  end
end

$cache = HashStore.new

class Story
  acts_as_cached($with_memcache ? {} : { :store => $cache })

  attr_accessor :id, :title

  def initialize(attributes = {})
    attributes.each { |key, value| instance_variable_set("@#{key}", value) }
  end

  def attributes
    { :id => id, :title => title }
  end

  def ==(other)
    attributes == other.attributes
  end

  def self.find(*args) 
    options = args.last.is_a?(Hash) ? args.pop : {}

    if (ids = args.flatten).size > 1
      ids.map { |id| $stories[id.to_i] }
    elsif (id = args.flatten.first).to_i.to_s == id.to_s
      $stories[id.to_i]
    end
  end

  def self.base_class
    Story
  end

  def self.something_cool; :redbull end

  def self.find_live(*args) false end
end

class Feature   < Story; end
class Interview < Story; end

module ActionController
  class Base
    def rendering_runtime(*args) '' end
    def self.silence; yield end
  end
end

class MemCache
  attr_accessor :servers
  def initialize(*args) end
  class MemCacheError < StandardError; end unless defined? MemCacheError
end unless $with_memcache

module StoryCacheSpecSetup
  def self.included(base)
    base.setup do 
      setup_cache_spec 
      Story.instance_eval { @max_key_length = nil }
    end
  end

  def setup_cache_spec
    @story  = Story.new(:id => 1, :title => "acts_as_cached 2 released!")
    @story2 = Story.new(:id => 2, :title => "BDD is something you can use")
    @story3 = Story.new(:id => 3, :title => "RailsConf is overrated.")
    $stories = { 1 => @story, 2 => @story2, 3 => @story3 }

    $with_memcache ? with_memcache : with_mock
  end

  def with_memcache
    unless $mc_setup_for_story_cache_spec
      ActsAsCached.config.clear
      config = YAML.load_file('defaults/memcached.yml.default')
      config['test'] = config['development'].merge('benchmarking' => false, 'disabled' => false)
      ActsAsCached.config = config
      $mc_setup_for_story_cache_spec = true
    end

    Story.send :acts_as_cached
    Story.expire_cache(1)
    Story.expire_cache(2)
    Story.expire_cache(3)
    Story.expire_cache(:block)
    Story.set_cache(2, @story2)
  end

  def with_mock
    $cache.clear

    Story.send :acts_as_cached, :store => $cache
    $cache['Story:2'] = @story2
  end
end

module FragmentCacheSpecSetup
  def self.included(base)
    base.setup { setup_fragment_spec }
  end
  
  def setup_fragment_spec
    unless $mc_setup_for_fragment_cache_spec
      ActsAsCached.config.clear
      config = YAML.load_file('defaults/memcached.yml.default')

      if $with_memcache
        other_options = { 'fragments' => true }
      else
        Object.const_set(:CACHE, $cache) unless defined? CACHE
        other_options = { 'fragments' => true, 'store' => $cache }
      end

      config['test'] = config['development'].merge other_options

      ActsAsCached.config = config
      ActsAsCached::FragmentCache.setup!
      $mc_setup_for_fragment_cache_spec = true
    end
  end
end
