require 'active_record/fixtures'

class CreateLicenses < ActiveRecord::Migration
  def self.up
    create_table :licenses do |t|
      t.column :name, :string
    end
    
    f = Fixtures.new(License.connection, # a database connection 
                      "licenses", # table name 
                      License, # model class 
                      File.join(File.dirname(__FILE__), "data/licenses")) 

    f.insert_fixtures
    
  end

  def self.down
    drop_table :licenses
  end
end
