class AddChangelogAndRoadmap < ActiveRecord::Migration
  def self.up
    add_column :projects, :changelog, :text
    add_column :projects, :roadmap, :text
  end

  def self.down
    remove_column :projects, :changelog
    remove_column :projects, :roadmap
  end
end
