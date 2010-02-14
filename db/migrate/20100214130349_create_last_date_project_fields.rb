class CreateLastDateProjectFields < ActiveRecord::Migration
  def self.up
    add_column "projects", "last_repository_date", :datetime
    add_column "projects", "last_file_date", :datetime
  end

  def self.down
    remove_column "projects", "last_repository_date"
    remove_column "projects", "last_file_date"
  end
end
