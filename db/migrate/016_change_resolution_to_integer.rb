class ChangeResolutionToInteger < ActiveRecord::Migration
  def self.up
    remove_column :bugs, :resolution_id
    add_column :bugs, :resolution_id, :integer
  end

  def self.down
    remove_column :bugs, :resolution_id
    add_column :bugs, :resolution_id,  :string
  end
end
