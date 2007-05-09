class FixBugIdStuff < ActiveRecord::Migration
  def self.up
    rename_column :bugs, :assigned_to, :assigned_to_id
    rename_column :bugs, :created_by, :created_by_id
  end

  def self.down
    rename_column :bugs, :assigned_to_id, :assigned_to
    rename_column :bugs, :created_by_id, :created_by
  end
end
