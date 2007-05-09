class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.column :project_id, :integer
      t.column :title, :string
      t.column :content, :text
      t.column :submitted_by, :integer
      t.column :is_on_front_page, :boolean, :default => false
      t.column :is_active, :boolean, :default => true
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :articles
  end
end
