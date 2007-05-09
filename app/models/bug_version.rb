class BugVersion < ActiveRecord::Base
  
  belongs_to :project
  has_many :bugs
  
  validates_presence_of :name, :project_id
  
end
