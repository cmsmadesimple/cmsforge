module Fguillen
  module Acts #:nodoc:
    module Historizable #:nodoc:

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_historizable
          has_many  :histories, 
                    :as => :historizable, 
                    :dependent => :destroy, 
                    :order => 'created_at DESC'
                    
          before_save :update_history
                    
          include Fguillen::Acts::Historizable::InstanceMethods
          extend Fguillen::Acts::Historizable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods

      end

      module InstanceMethods
        def update_history
          if self.changed? && !self.new_record?
            historizable = self.class.base_class.name

            history = 
              History.create!(
                :historizable_type => historizable,
                :historizable_id   => self.id
              )
              
            self.changed.each do |field_changed|
              was, actual = self.send( "#{field_changed}_change" )
              history_line = 
                HistoryLine.create!(
                  :history_id         => history.id,
                  :field_name         => field_changed,
                  :field_value_was    => was.to_s,
                  :field_value_actual => actual.to_s
                )
            end
          end
        end
      end
      
    end
  end
end
