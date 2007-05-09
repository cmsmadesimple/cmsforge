class AddEnumTable < ActiveRecord::Migration
  def self.up
    create_table :enumrecords do |t|
      t.column :name, :string
      t.column :type, :string
      t.column :position, :integer, :default => 1
    end
    
    f = Fixtures.new(EnumRecord.connection, # a database connection 
                      "enumrecords", # table name 
                      EnumRecord, # model class 
                      File.join(File.dirname(__FILE__), '..', '..', "spec/fixtures/enum")) 

    f.insert_fixtures
    
  end

  def self.down
    drop_table :enumrecords
  end
end
