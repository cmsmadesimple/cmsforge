class TrackerItem < ActiveRecord::Base
  
  belongs_to :project
  belongs_to :assigned_to, :class_name => "User", :foreign_key => "assigned_to_id"
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by_id"
  belongs_to :version, :class_name => "BugVersion", :foreign_key => "version_id"
  
  validates_presence_of :summary, :description, :created_by, :project_id
  
  has_enumerated :severity, :class_name => 'BugSeverity', :foreign_key => 'severity_id'
  has_enumerated :resolution, :class_name => 'BugResolution', :foreign_key => 'resolution_id'
  
  #acts_as_cached
  acts_as_commentable
  
  acts_as_historizable

  cattr_reader :per_page
  @@per_page = 10
  
  def assigned_to_string
    self.assigned_to_id > 0 ? User.find(self.assigned_to_id).full_name : 'None'
  end
  
  def created_by_string
    self.created_by_id > 0 ? User.find(self.created_by_id).full_name : 'None'
  end
  
  def resolution_string
    !self.resolution.nil? ? self.resolution.name : 'None'
  end
  
  def state_string
    !self.state.nil? ? self.state : 'None'
  end
  
  def after_save
    send_later(:send_email)
  end

end
