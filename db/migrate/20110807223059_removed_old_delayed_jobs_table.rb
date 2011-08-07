class RemovedOldDelayedJobsTable < ActiveRecord::Migration
  def up
    drop_table :delayed_jobs
  end

  def down
    create_table :delayed_jobs, :force => true do |table|
      table.integer  :priority, :default => 0
      table.integer  :attempts, :default => 0
      table.text     :handler
      table.string   :last_error
      table.datetime :run_at
      table.datetime :locked_at
      table.string   :locked_by
      table.timestamps
    end
  end
end
