class BugVersion < ActiveRecord::Base
  
  belongs_to :project
  has_many :bugs, :foreign_key => 'version_id', :dependent => :destroy
  
  validates_presence_of :name, :project_id
  
end
