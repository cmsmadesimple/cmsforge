class AddNumberOfDownloadsToReleasedFiles < ActiveRecord::Migration
  def self.up
    add_column :released_files, :downloads, :integer, :default => 0
  end

  def self.down
    remove_column :released_files, :downloads
  end
end
