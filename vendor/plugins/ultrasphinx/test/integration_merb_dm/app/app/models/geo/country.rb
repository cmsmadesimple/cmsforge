class Geo::Country
  include DataMapper::Resource

  storage_names[default_repository_name] = 'countries'

  property :id,   Integer, :serial => true
  property :name, String
  
  is_indexed :fields => ['name']
end
