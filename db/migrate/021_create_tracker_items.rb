class CreateTrackerItems < ActiveRecord::Migration
  def self.up
    rename_table('bugs', 'tracker_items')
  end

  def self.down
    rename_table('tracker_items', 'bugs')
  end
end
