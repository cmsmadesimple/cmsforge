class AddActiveFlagToBugVersions < ActiveRecord::Migration
  def self.up
    add_column :bug_versions, :is_active, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :bug_versions, :is_active
  end
end
