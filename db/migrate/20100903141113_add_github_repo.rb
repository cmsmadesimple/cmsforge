class AddGithubRepo < ActiveRecord::Migration
  def self.up
    add_column :projects, :github_repo, :string, :default => ''
  end

  def self.down
    remove_column :projects, :github_repo
  end
end
