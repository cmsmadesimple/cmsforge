class RemoveIsActiveFromProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :is_active
  end

  def self.down
    add_column :projects, :is_active, :boolean, :default => false
  end
end
