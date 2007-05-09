class Bug < ActiveRecord::Base
  
  belongs_to :project
  belongs_to :assigned_to, :class_name => "User", :foreign_key => "assigned_to_id"
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by_id"
  belongs_to :version, :class_name => "BugVersion", :foreign_key => "version_id"
  
  validates_presence_of :summary, :description, :created_by, :project_id
  
  has_enumerated :severity, :class_name => 'BugSeverity', :foreign_key => 'severity_id'
  has_enumerated :resolution, :class_name => 'BugResolution', :foreign_key => 'resolution_id'
  
  acts_as_commentable
  
end
