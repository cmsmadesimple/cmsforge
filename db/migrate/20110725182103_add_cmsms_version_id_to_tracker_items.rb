class AddCmsmsVersionIdToTrackerItems < ActiveRecord::Migration
  def self.up
    add_column :tracker_items, :cmsms_version_id, :integer
  end

  def self.down
    remove_column :tracker_items, :cmsms_version_id
  end
end
