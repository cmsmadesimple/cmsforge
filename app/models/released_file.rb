class ReleasedFile < ActiveRecord::Base
  
  belongs_to :release
  
  validates_presence_of :file_file_name, :release_id
  
  has_attached_file :file,
    :storage => :s3,
    :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
    :path => "downloads/:id/:filename"

  #has_attachment  :storage => :s3,
                  #:path_prefix => "downloads",
                  #:max_size => 25.megabytes

  #validates_as_attachment
  
  def download_path
    "http://dev.cmsmadesimple.org/frs/download.php/#{self.id}/#{self.file_file_name}".html_safe
  end

end
