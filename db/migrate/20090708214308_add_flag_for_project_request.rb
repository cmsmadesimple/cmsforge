class AddFlagForProjectRequest < ActiveRecord::Migration
  def self.up
    add_column "projects", "show_join_request", :boolean, :default => false
  end

  def self.down
    remove_column "projects", "show_join_request"
  end
end
