require 'spec_helper'

describe Goc::Core do
  let(:user_a) { FactoryGirl.create(:user) }
  
  it "Find the current user by id" do
    Goc::Core.get_resource(user_a.id).should == user_a
  end

end