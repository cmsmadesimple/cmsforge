class HistoryLine < ActiveRecord::Base
  belongs_to :history
  
  def to_s
    "#{self.field_name}: #{self.field_value_was} => #{self.field_value_actual}"
  end
end
