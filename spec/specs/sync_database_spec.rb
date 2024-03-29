require 'spec_helper'

describe "Goc: database sync support" do
  let(:user_a) { FactoryGirl.create(:user) }
  let(:user_b) { FactoryGirl.create(:user) }
  let(:user_c) { FactoryGirl.create(:user) }

  context "Running database sync rake task to simulate production environment" do

    before(:all) do
      User.delete_all
      Badge.delete_all
      Domain.delete_all
      Rating.delete_all
    end

    context "Using rake goc:sync_database to recreate all badges and relations" do
    
      before :all do
        `cd #{Rails.root}/; rake goc:sync_database`
      end

      it "All Badges and Domains should be created" do
        Badge.all.size.should == 4
        Domain.all.size.should  == 1
      end

      it "Domain teacher should not exist" do
        Domain.find_by_name("teacher").should be_nil
      end
    
    end

  end

end