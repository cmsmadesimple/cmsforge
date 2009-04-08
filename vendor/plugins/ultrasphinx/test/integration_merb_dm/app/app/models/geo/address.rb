class Geo::Address
  include DataMapper::Resource
  
  storage_names[default_repository_name] = 'addresses'

  property :id,               Integer, :serial => true
  property :user_id, Integer
  property :name, String
  property :line_1, String
  property :line_2, String
  property :city, String
  property :province_region, String
  property :zip_postal_code, String
  property :country_id, Integer
  property :lat, Float
  property :lng, Float
  
  belongs_to :user
  belongs_to :state, :class_name => 'Geo::State'
  
  is_indexed 'fields' => ['name', {:field => 'lat', :function_sql => "RADIANS(?)"}, {:field => 'lng', :function_sql => "RADIANS(?)"}],
    'concatenate' => [{'fields' => ['line_1', 'line_2', 'city', 'province_region', 'zip_postal_code'], 'as' => 'content'}],
    'include' => [{'association_name' => 'state', 'field' => 'name', 'as' => 'state'}],
    'delta' => true
end
