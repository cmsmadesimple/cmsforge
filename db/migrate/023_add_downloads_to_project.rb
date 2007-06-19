class AddDownloadsToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :downloads, :integer
  end

  def self.down
    remove_column :projects, :downloads
  end
end
