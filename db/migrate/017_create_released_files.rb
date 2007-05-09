class CreateReleasedFiles < ActiveRecord::Migration
  def self.up
    create_table :released_files do |t|
      t.column :release_id, :integer
      t.column :filename, :string
      t.column :filesize, :integer
      t.column :deleted_at, :datetime
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :released_files
  end
end
