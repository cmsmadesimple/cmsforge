class AddProjectRequests < ActiveRecord::Migration
  def self.up
    create_table :project_join_requests, :force => true do |t|
      t.integer   :project_id
      t.integer   :user_id
      t.text      :message
      t.string    :state, :default => "pending"
      t.timestamps
    end
  end

  def self.down
    drop_table :project_join_requests
  end
end
