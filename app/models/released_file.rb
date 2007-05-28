class ReleasedFile < ActiveRecord::Base
  
  belongs_to :release
  
  validates_presence_of :filename, :release_id
  
  acts_as_paranoid
  
  def download_path
    "http://dev.cmsmadesimple.org/frs/download.php/#{self.id}/#{self.filename}"
  end

end
