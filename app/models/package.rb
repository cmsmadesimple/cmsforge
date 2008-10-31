class Package < ActiveRecord::Base
  
  belongs_to :project
  has_many :releases
  has_many :articles
  
  validates_presence_of :name, :project_id
  
  acts_as_activated
  
  acts_as_followable
  
  def latest_release
    self.releases.find :first, :order => 'created_at DESC'
  end

end
