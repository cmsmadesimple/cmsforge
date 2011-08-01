class FromAttachmentfuToPaperclip < ActiveRecord::Migration
  def up
    #Reorganise the actual photos on AWS to suit the RWS/Paperclip schema
    #Rename attachement_fu columns to paperclip convention
    rename_column :released_files, :filename, :file_file_name
    rename_column :released_files, :content_type, :file_content_type
    rename_column :released_files, :size, :file_file_size
  end

  def down
  end
end
