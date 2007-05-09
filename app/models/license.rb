class License < ActiveRecord::Base
  
  has_many :projects
  
  def to_s
    self.name
  end
  
end
