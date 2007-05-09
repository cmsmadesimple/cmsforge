class CreateBugVersions < ActiveRecord::Migration
  def self.up
    create_table :bug_versions do |t|
      t.column :project_id, :integer
      t.column :name, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :bug_versions
  end
end
