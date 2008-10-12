class AddFieldsForFrsFiles < ActiveRecord::Migration
  def self.up
    add_column :released_files, :content_type, :string
    rename_column :released_files, :filesize, :size
  end

  def self.down
    remove_column :released_files, :content_type
    rename_column :released_files, :size, :filesize
  end
end
