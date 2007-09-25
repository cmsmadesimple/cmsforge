class Project < ActiveRecord::Base
  
  has_many :assignments
  has_many :users, :through => :assignments
  has_many :packages
  has_many :releases, :through => :packages, :order => 'id DESC'
  has_many :articles
  has_many :bugs
  has_many :feature_requests
  has_many :bug_versions
  
  belongs_to :license
  
  acts_as_activated
  acts_as_commentable
  acts_as_taggable
  
  acts_as_state_machine :initial => :pending
  state :pending
  state :accepted, :after => :after_accepted
  state :rejected, :after => :after_rejected
  
  event :accept do
    transitions :to => :accepted, :from => :pending
  end
  
  event :reject do
    transitions :to => :rejected, :from => :pending
  end
  
  #validates_presence_of     :name, :unix_name, :description, :registration_reason, :project_type
  validates_presence_of     :name, :unix_name, :description, :registration_reason
  validates_length_of       :name, :within => 3..40, :allow_nil => true
  validates_length_of       :unix_name, :within => 3..15, :allow_nil => true
  validates_uniqueness_of   :name, :case_sensitive => false, :allow_nil => true
  validates_uniqueness_of   :unix_name, :case_sensitive => false, :allow_nil => true
  validates_format_of       :unix_name, :with => /^[a-z][a-z_]+$/, :allow_nil => true
  
  def home_page
    "/projects/#{self.unix_name}"
  end
  
  def name_and_home_page
    "<a href=\"#{self.home_page}\">#{self.name}</a>"
  end
  
  def approved_date
    #Projects coming over from gforge don't have an approved_on.  So we fake it.
    unless self.approved_on.nil?
      self.approved_on
    end
    return self.created_at
  end
  
  def after_accepted
    self.is_active = true
    self.approved_on = Datetime.now
    unless current_user.nil?
      self.approved_by = current_user.id
    end
  end
  
  def after_rejected
    self.is_active = false
  end
  
end
