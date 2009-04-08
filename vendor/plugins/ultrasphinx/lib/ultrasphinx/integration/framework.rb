if defined?(RAILS_ENV) or defined?(Rails)
  require 'ultrasphinx/integration/rails'
elsif defined?(Merb)
  require 'ultrasphinx/integration/merb'
else
  raise LoadError, "Ultrasphinx only supports Rails and Merb, please require it after the framework has initialized."
end
