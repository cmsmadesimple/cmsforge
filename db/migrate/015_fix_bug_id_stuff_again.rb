class FixBugIdStuffAgain < ActiveRecord::Migration
  def self.up
    rename_column :bugs, :resolution, :resolution_id
    rename_column :bugs, :severity, :severity_id
  end

  def self.down
    rename_column :bugs, :resolution_id, :resolution
    rename_column :bugs, :severity_id, :severity
  end
end
