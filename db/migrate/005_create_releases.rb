class CreateReleases < ActiveRecord::Migration
  def self.up
    create_table :releases do |t|
      t.column :package_id, :integer
      t.column :name, :string
      t.column :release_notes, :text
      t.column :changelog, :text
      t.column :released_by, :integer
      t.column :is_active, :boolean, :default => true
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :releases
  end
end
