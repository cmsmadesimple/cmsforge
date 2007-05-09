class ReleasedFile < ActiveRecord::Base
  
  belongs_to :release
  
  validates_presence_of :filename, :release_id
  
  acts_as_paranoid

end
