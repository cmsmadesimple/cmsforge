if defined?(ActiveRecord)
  require 'ultrasphinx/integration/active_record'
elsif defined?(DataMapper)
  require 'ultrasphinx/integration/datamapper'
else
  raise "No ORM found, Ultrasphinx only supports ActiveRecord and DataMapper, please require it after your ORM library has been loaded."
end
