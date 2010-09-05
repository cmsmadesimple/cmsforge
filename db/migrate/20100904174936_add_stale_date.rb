class AddStaleDate < ActiveRecord::Migration
  def self.up
    add_column "projects", "freshness_date", :datetime
  end

  def self.down
    remove_column "projects", "freshness_date", :datetime
  end
end
