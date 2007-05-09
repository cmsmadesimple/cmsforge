class CreateBugs < ActiveRecord::Migration
  def self.up
    create_table :bugs do |t|
      t.column :project_id, :integer
      t.column :assigned_to, :integer
      t.column :version_id, :integer
      t.column :resolution, :string
      t.column :created_by, :integer
      t.column :severity, :integer
      t.column :state, :string
      t.column :summary, :string
      t.column :description, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :bugs
  end
end
