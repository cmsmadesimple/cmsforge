class Category
  include DataMapper::Resource

  property :id,             Integer, :serial => true
  property :name,           String
  property :parent_id,      Integer
  property :children_count, Integer
  property :permalink,      String

  has n, :sellers, :through => Resource
  
end
