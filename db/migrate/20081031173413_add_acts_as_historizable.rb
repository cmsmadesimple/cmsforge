class AddActsAsHistorizable < ActiveRecord::Migration
  def self.up
    create_table :histories, :force => true do |t|
      t.integer   :historizable_id,        :null => false
      t.string    :historizable_type,      :null => false
      t.datetime  :created_at,             :null => false
    end
    
    create_table :history_lines, :force => true do |t|
      t.integer   :history_id,          :null => false
      t.string    :field_name,          :null => false
      t.string    :field_value_was,     :null => false
      t.string    :field_value_actual,  :null => false
    end
  end

  def self.down
    drop_table :history_lines
    drop_table :histories
  end
end
