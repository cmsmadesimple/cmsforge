require File.dirname(__FILE__) + '/../spec_helper'

module ProjectSpecHelper
  def valid_project_attributes
    { :name => 'Project Name',
      :unix_name => 'project_name',
      :description => 'This is the description.',
      :registration_reason => 'This is why?',
      :project_type => 'module',
      :project_category => 'somecategory',
      :state => 'pending',
      :license_id => 100 }
  end
end

describe "A project" do
  
  include ProjectSpecHelper

  before(:each) do
    # fixtures are setup before this
    @project = Project.new
  end
  
  it "should be invalid without a name" do
    @project.attributes = valid_project_attributes.except(:name)
    @project.should_not be_valid
    @project.errors.on(:name).should include("can't be blank")
    @project.name = valid_project_attributes[:name]
    @project.should be_valid
  end
  
  it "should be invalid with less than 3 or more than 40 characters" do
    @project.attributes = valid_project_attributes
    @project.name = 'mm' #Too short
    @project.should_not be_valid
    @project.name = "1234567890123456789012345678901234567890123" #Too long
    @project.should_not be_valid
    @project.name = valid_project_attributes[:name]
    @project.should be_valid
  end
  
  it "should be invalid without a unix name" do
    @project.attributes = valid_project_attributes.except(:unix_name)
    @project.should_not be_valid
    @project.errors.on(:unix_name).should include("can't be blank")
    @project.unix_name = valid_project_attributes[:unix_name]
    @project.should be_valid
  end
  
  it "should be invalid with bad unix names" do
    @project.attributes = valid_project_attributes
    @project.unix_name = '_starts_uc'
    @project.should_not be_valid
    @project.unix_name = 'CapLetter'
    @project.should_not be_valid
    @project.unix_name = 'uc_in_middle'
    @project.should be_valid
    @project.unix_name = ' a_space'
    @project.should_not be_valid
    @project.unix_name = 'ss' #Too Short
    @project.should_not be_valid
    @project.unix_name = 'this_is_too_lang_the_minimum_is_15_chars'
    @project.should_not be_valid
    @project.unix_name = 'just_right'
    @project.should be_valid
  end

  it "should not be able to duplicate names or unix names" do
    @project.attributes = valid_project_attributes
    @project.should be_valid
    @project.save
    project2 = Project.new
    project2.attributes = valid_project_attributes
    project2.should_not be_valid
    project2.name = 'This is a different project'
    project2.should_not be_valid
    project2.unix_name = 'different'
    project2.should be_valid
    @project.destroy
  end
  
  it "should be valid with a full set of valid attributes" do
    @project.attributes = valid_project_attributes
    @project.should be_valid
  end
  
  it "should give back a proper home page url" do
    @project.attributes = valid_project_attributes
    @project.home_page.should == '/project/' + valid_project_attributes[:unix_name]
  end
  
  it "should give back an assigned license" do
    @project.attributes = valid_project_attributes
    @project.license.to_s.should == 'None'
  end

  after(:each) do
    # fixtures are torn down after this
  end

end
