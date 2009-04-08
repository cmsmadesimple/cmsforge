class Seller
  include DataMapper::Resource

  property :id,                Integer, :serial => true
  property :company_name,      String
  property :created_at,        DateTime
  property :updated_at,        DateTime
  property :capitalization,    Float
  property :mission_statement, String
  property :user_id,           Integer
  
  belongs_to :user  
  delegate :address, :to => :user
  
  is_indexed :fields => [
    {:field => :company_name, :facet => true, :sortable => true},
    {:field => 'mission_statement', :sortable => true},
    'created_at', 
    :capitalization, 
    :user_id
  ],
    :delta => true
  
  def name 
    company_name
  end
  
  def metadata
    "sfdkjl fsdjkl sdfjl fdsjk #{company_name} " * 5
  end  
end
