class AddNextPlannedReleaseToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :next_planned_release, :datetime
  end

  def self.down
    remove_column :projects, :next_planned_release
  end
end
