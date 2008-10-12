class ReleasedFile < ActiveRecord::Base
  
  belongs_to :release
  
  validates_presence_of :filename, :release_id
  
  has_attachment :storage => :file_system, 
                 :max_size => 10.megabytes

  validates_as_attachment
  
  def download_path
    "http://dev.cmsmadesimple.org/frs/download.php/#{self.id}/#{self.filename}"
  end

end
