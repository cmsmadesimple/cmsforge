class CreatePackages < ActiveRecord::Migration
  def self.up
    create_table :packages do |t|
      t.column :project_id, :integer
      t.column :name, :string
      t.column :is_public, :boolean, :default => true
      t.column :is_active, :boolean, :default => true
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :packages
  end
end
