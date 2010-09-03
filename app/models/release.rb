class Release < ActiveRecord::Base
  
  belongs_to :package
  has_many :released_files, :order => 'filename ASC'
  
  validates_presence_of :name, :package_id
  
  acts_as_activated
  
  def before_delete
    
  end

end
