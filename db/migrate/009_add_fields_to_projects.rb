class AddFieldsToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :is_active, :boolean, :default => false
    add_column :projects, :state, :string, :default => 'pending' 
    add_column :projects, :approved_on, :datetime
    add_column :projects, :approved_by, :integer
    add_column :projects, :reject_reason, :text
    add_column :projects, :license_id, :integer
  end

  def self.down
    remove_column :projects, :is_active
    remove_column :projects, :state
    remove_column :projects, :approved_on
    remove_column :projects, :approved_by
    remove_column :projects, :reject_reason
    remove_column :projects, :license_id
  end
end
