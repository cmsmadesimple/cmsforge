
require "#{File.dirname(__FILE__)}/../test_helper"
require 'mocha'

class AbstractConfigureTest < Test::Unit::TestCase
  class User; end
  class Seller; end
  module Geo
    class Address; end
    class State; end
    class Country; end
  end
  
  def setup
    load_constants
  end

private
  def load_constants
    Ultrasphinx::Configure.stubs(:load_constants)
    f = Ultrasphinx::Fields.instance
    #<Ultrasphinx::Fields:0x2516308
    # @classes={"company"=>[User(id: integer, login: string, email: string, crypted_password: string, salt: string, created_at: datetime, updated_at: datetime, deleted: boolean)], "name"=>[Geo::Address(id: integer, user_id: integer, name: string, line_1: string, line_2: string, city: string, state_id: integer, province_region: string, zip_postal_code: string, country_id: integer, lat: float, lng: float), Geo::Country(id: integer, name: string)], "address_name"=>[Geo::State(id: integer, name: string, abbreviation: string)], "company_two_facet"=>[User(id: integer, login: string, email: string, crypted_password: string, salt: string, created_at: datetime, updated_at: datetime, deleted: boolean)], "company_name"=>[Seller(id: integer, user_id: integer, company_name: string, created_at: datetime, updated_at: datetime, capitalization: float, mission_statement: string)], "class"=>[Geo::State(id: integer, name: string, abbreviation: string), Seller(id: integer, user_id: integer, company_name: string, created_at: datetime, updated_at: datetime, capitalization: float, mission_statement: string), Geo::Address(id: integer, user_id: integer, name: string, line_1: string, line_2: string, city: string, state_id: integer, province_region: string, zip_postal_code: string, country_id: integer, lat: float, lng: float), User(id: integer, login: string, email: string, crypted_password: string, salt: string, created_at: datetime, updated_at: datetime, deleted: boolean), Geo::Country(id: integer, name: string)], "class_id"=>[Geo::State(id: integer, name: string, abbreviation: string), Seller(id: integer, user_id: integer, company_name: string, created_at: datetime, updated_at: datetime, capitalization: float, mission_statement: string), Geo::Address(id: integer, user_id: integer, name: string, line_1: string, line_2: string, city: string, state_id: integer, province_region: string, zip_postal_code: string, country_id: integer, lat: float, lng: float), User(id: integer, login: string, email: string, crypted_password: string, salt: string, created_at: datetime, updated_at: datetime, deleted: boolean), Geo::Country(id: integer, name: string)], "lng"=>[Geo::Address(id: integer, user_id: integer, name: string, line_1: string, line_2: string, city: string, state_id: integer, province_region: string, zip_postal_code: string, country_id: integer, lat: float, lng: float)], "capitalization"=>[Seller(id: integer, user_id: integer, company_name: string, created_at: datetime, updated_at: datetime, capitalization: float, mission_statement: string)], "deleted"=>[User(id: integer, login: string, email: string, crypted_password: string, salt: string, created_at: datetime, updated_at: datetime, deleted: boolean)], "content"=>[Geo::Address(id: integer, user_id: integer, name: string, line_1: string, line_2: string, city: string, state_id: integer, province_region: string, zip_postal_code: string, country_id: integer, lat: float, lng: float)], "user_id"=>[Seller(id: integer, user_id: integer, company_name: string, created_at: datetime, updated_at: datetime, capitalization: float, mission_statement: string)], "login"=>[User(id: integer, login: string, email: string, crypted_password: string, salt: string, created_at: datetime, updated_at: datetime, deleted: boolean)], "lat"=>[Geo::Address(id: integer, user_id: integer, name: string, line_1: string, line_2: string, city: string, state_id: integer, province_region: string, zip_postal_code: string, country_id: integer, lat: float, lng: float)], "mission_statement_sortable"=>[Seller(id: integer, user_id: integer, company_name: string, created_at: datetime, updated_at: datetime, capitalization: float, mission_statement: string)], "company_name_facet"=>[Seller(id: integer, user_id: integer, company_name: string, created_at: datetime, updated_at: datetime, capitalization: float, mission_statement: string)], "company_two"=>[User(id: integer, login: string, email: string, crypted_password: string, salt: string, created_at: datetime, updated_at: datetime, deleted: boolean)], "company_facet"=>[User(id: integer, login: string, email: string, crypted_password: string, salt: string, created_at: datetime, updated_at: datetime, deleted: boolean)], "email"=>[User(id: integer, login: string, email: string, crypted_password: string, salt: string, created_at: datetime, updated_at: datetime, deleted: boolean)], "state"=>[Geo::Address(id: integer, user_id: integer, name: string, line_1: string, line_2: string, city: string, state_id: integer, province_region: string, zip_postal_code: string, country_id: integer, lat: float, lng: float)], "created_at"=>[Seller(id: integer, user_id: integer, company_name: string, created_at: datetime, updated_at: datetime, capitalization: float, mission_statement: string)], "mission_statement"=>[Seller(id: integer, user_id: integer, company_name: string, created_at: datetime, updated_at: datetime, capitalization: float, mission_statement: string)], "company_name_sortable"=>[Seller(id: integer, user_id: integer, company_name: string, created_at: datetime, updated_at: datetime, capitalization: float, mission_statement: string)]}, 
    f.classes.merge!(
      "address_name"                => [Geo::State], 
      "capitalization"              => [Seller], 
      "class"                       => [Geo::State, Seller, Geo::Address, User, Geo::Country], 
      "class_id"                    => [Geo::State, Seller, Geo::Address, User, Geo::Country], 
      "company"                     => [User], 
      "company_facet"               => [User], 
      "company_name"                => [Seller], 
      "company_name_facet"          => [Seller], 
      "company_name_sortable"       => [Seller],
      "company_two"                 => [User], 
      "company_two_facet"           => [User], 
      "content"                     => [Geo::Address], 
      "created_at"                  => [Seller], 
      "deleted"                     => [User], 
      "email"                       => [User], 
      "lat"                         => [Geo::Address], 
      "lng"                         => [Geo::Address], 
      "login"                       => [User], 
      "mission_statement"           => [Seller], 
      "mission_statement_sortable"  => [Seller], 
      "name"                        => [Geo::Address, Geo::Country], 
      "state"                       => [Geo::Address], 
      "user_id"                     => [Seller]
    )
    # @types={"company"=>"text", "name"=>"text", "address_name"=>"text", "company_two_facet"=>"integer", "company_name"=>"text", "class"=>"text", "class_id"=>"integer", "lng"=>"float", "capitalization"=>"float", "deleted"=>"bool", "content"=>"text", "user_id"=>"integer", "login"=>"text", "lat"=>"float", "mission_statement_sortable"=>"text", "company_name_facet"=>"integer", "company_two"=>"text", "company_facet"=>"integer", "email"=>"text", "state"=>"text", "created_at"=>"date", "mission_statement"=>"text", "company_name_sortable"=>"text"},
    f.types.merge!(
      "address_name"=>"text", 
      "capitalization"=>"float", 
      "class"=>"text", 
      "class_id"=>"integer", 
      "company"=>"text", 
      "company_facet"=>"integer", 
      "company_name"=>"text", 
      "company_name_facet"=>"integer", 
      "company_name_sortable"=>"text",
      "company_two"=>"text", 
      "company_two_facet"=>"integer", 
      "content"=>"text", 
      "created_at"=>"date", 
      "deleted"=>"bool", 
      "email"=>"text", 
      "lat"=>"float", 
      "lng"=>"float", 
      "login"=>"text", 
      "mission_statement"=>"text", 
      "mission_statement_sortable"=>"text", 
      "name"=>"text", 
      "state"=>"text", 
      "user_id"=>"integer"
    )
    # @groups=["sql_attr_uint = class_id", nil, nil, nil, "sql_attr_uint = company_name_facet", "sql_attr_str2ordinal = company_name_sortable", nil, "sql_attr_str2ordinal = mission_statement_sortable", "sql_attr_timestamp = created_at", "sql_attr_float = capitalization", "sql_attr_uint = user_id", nil, "sql_attr_float = lat", "sql_attr_float = lng", nil, nil, nil, nil, "sql_attr_bool = deleted", nil, "sql_attr_uint = company_facet", nil, "sql_attr_uint = company_two_facet"]>
    f.instance_variable_get('@groups').replace(
      ["sql_attr_uint = class_id", nil, nil, nil, "sql_attr_uint = company_name_facet", "sql_attr_str2ordinal = company_name_sortable", nil, "sql_attr_str2ordinal = mission_statement_sortable", "sql_attr_timestamp = created_at", "sql_attr_float = capitalization", "sql_attr_uint = user_id", nil, "sql_attr_float = lat", "sql_attr_float = lng", nil, nil, nil, nil, "sql_attr_bool = deleted", nil, "sql_attr_uint = company_facet", nil, "sql_attr_uint = company_two_facet"]
    )
  end

end

class ConfigureIntegrationTest < AbstractConfigureTest
  def test_integration
    canonical_output = File.read("#{File.dirname(__FILE__)}/../integration/app/config/ultrasphinx/development.conf.canonical")
    # strip leading, dynamic comments
    expected_output = canonical_output.split("\n")[4..-1].join("\n")
    
    conf = StringIO.new("", "w")
    File.expects(:open).with(Ultrasphinx::CONF_PATH, 'w').yields(conf)
    
    Ultrasphinx::Configure.new.run
    
    # strip leading, dynamic comments
    actual_output = conf.string.split("\n")[4..-1].join("\n")
    assert_equal expected_output, actual_output
  end
end

class ConfigureUnitTest < AbstractConfigureTest
  def setup
    super
    @conf = Ultrasphinx::Configure.new
  end
  
  def test_run_should_load_constants
    Ultrasphinx::Configure.stubs(:load_constants)
    @conf.run
  end
  
  def test_run_should_write_to_s_to_a_file
    conf = mock(:puts => 'hi')
    File.expects(:open).with(Ultrasphinx::CONF_PATH, 'w').yields(conf)
    @conf.expects(:to_s).returns('hi')
    
    @conf.run
  end
  
  def test_to_s_should_combine_global_header_with_index_configurations
    @conf.expects(:global_header).returns(['head'])
    @conf.expects(:index_configuration).returns(['source','source','index'])
    
    assert_equal "head\nsource\nsource\nindex", @conf.to_s
  end
  
  def test_global_header_should_include_indexer_settings
  end
  
  def test_global_header_should_include_daemon_settings
  end
  
  def test_index_configuration_
  end
end

class IndexConfigurationTest < AbstractConfigureTest
  def setup
    super
    @index = Ultrasphinx::IndexConfiguration.new('main')
    @delta_index = Ultrasphinx::IndexConfiguration.new('delta')
  end
  
  def test_to_s_should_join_config_lines
    @index.expects(:config).returns(["a", "b\n", "cc"])
    assert_equal "a\nb\ncc", @index.to_s
  end
  
  def test_config_should_process_model_configuraitons
  end
  
  def test_config_should_append_index_configuration
  end
  
  def test_index_config_should_return_empty_if_no_sources_found
  end
  
  def test_index_config_should_reference_indexed_sources
  end
  
  def test_index_config_should_include_index_settings
  end
  
  def test_process_source_should_use_a_source_configuration_config
  end
end

class SourceConfigurationTest < AbstractConfigureTest
  def setup
    super
    #
  end
  
  def test_config_eh_is_true_if_index_name_is_not_delta_index
  end
  
  def test_config_eh_is_true_if_delta_option_is_true
    # TODO: I think this logic might be backwards
  end
  
  def test_config_eh_is_false_otherwise
  end
  
  def test_config_should_include_source_settings
  end

  def test_config_should_include_source_database_string
  end

  def test_config_should_include_range_select_string
  end

  def test_config_should_include_query_string
  end

  def test_config_should_include_groups
  end

  def test_config_should_include_query_info_string
  end

end
