require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe States, "index action" do
  before(:each) do
    dispatch_to(States, :index)
  end
end