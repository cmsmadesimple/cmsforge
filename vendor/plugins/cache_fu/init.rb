require 'memcache'
require 'acts_as_cached'

Object.send :include, ActsAsCached::Mixin

unless File.exists? config_file = File.join(RAILS_ROOT, 'config', 'memcached.yml')
  error = "No config file found.  Make sure you used `script/plugin install' and have memcached.yml in your config directory."
  puts error
  logger.error error
  exit!
end

ActsAsCached.config = YAML.load_file(config_file)
