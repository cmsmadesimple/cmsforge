class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      t.column :project_id, :integer
      t.column :user_id, :integer
      t.column :role, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :assignments
  end
end
