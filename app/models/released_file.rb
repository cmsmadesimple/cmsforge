class ReleasedFile < ActiveRecord::Base
  
  belongs_to :release
  
  validates_presence_of :filename, :release_id
  
  #has_attachment  :storage => :s3,
                  #:path_prefix => "downloads",
                  #:max_size => 25.megabytes

  #validates_as_attachment
  
  def download_path
    "http://dev.cmsmadesimple.org/frs/download.php/#{self.id}/#{self.filename}".html_safe
  end

end
