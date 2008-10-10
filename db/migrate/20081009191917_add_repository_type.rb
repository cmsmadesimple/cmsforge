class AddRepositoryType < ActiveRecord::Migration
  def self.up
    add_column :projects, :repository_type, :string, :default => 'svn'
  end

  def self.down
    remove_column :projects, :repository_type
  end
end
