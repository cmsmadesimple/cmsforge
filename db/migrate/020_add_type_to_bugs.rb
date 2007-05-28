class AddTypeToBugs < ActiveRecord::Migration
  def self.up
    add_column :bugs, :type, :string
    execute 'UPDATE bugs set type = \'Bug\''
  end

  def self.down
    remove_column :bugs, :type
  end
end
