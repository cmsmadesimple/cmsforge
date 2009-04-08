class Geo::State
  include DataMapper::Resource

  storage_names[default_repository_name] = 'states'

  property :id,           Integer, :serial => true
  property :name,         String
  property :abbreviation, String
  
  has n, :addresses, :class_name => "Geo::Address"
  
  is_indexed :concatenate => [{:class_name => 'Geo::Address', :field => 'name', :as => 'address_name'}]
    #:fields => [{:field => 'abbreviation', :as => 'company_name'}],
end
