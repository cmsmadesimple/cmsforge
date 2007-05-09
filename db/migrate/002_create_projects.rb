class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.column :name, :string
      t.column :unix_name, :string
      t.column :description, :text
      t.column :registration_reason, :text
      t.column :project_type, :string
      t.column :project_category, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :projects
  end
end
