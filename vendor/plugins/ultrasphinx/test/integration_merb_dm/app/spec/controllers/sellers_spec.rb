require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Sellers, "index action" do
  before(:each) do
    dispatch_to(Sellers, :index)
  end
end