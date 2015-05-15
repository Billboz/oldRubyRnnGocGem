require 'spec_helper'

describe Goc do
  let(:user) { FactoryGirl.create(:user) }
  let(:domain) { Domain.find_by_name "comments" }
  let(:noob_badge) { Badge.find_by_name "noob" }
  let(:medium_badge) { Badge.find_by_name "medium" }
  let(:hard_badge) { Badge.find_by_name "hard" }

  describe "Get a new resource and add and remove badges to it" do

    context "Adding a badge to an user" do

      it "Add the noob badge and the ratings related to an user" do
        noob_badge.add(user.id)
        user.reload
        user.badges.should include noob_badge
        user.ratings.where(:domain_id => domain.id).sum(:value) == noob_badge.ratings
      end

    end

    context "Removing a badge to an user" do

      before(:each) do
        Rating.destroy_all
        noob_badge.add(user.id)
        hard_badge.add(user.id)
      end

      it "Remove the medium badge and the ratings related" do
        hard_badge.remove(user.id)
        user.reload
        user.badges.should_not include hard_badge
        user.ratings.where(:domain_id => domain.id).sum(:value) == medium_badge.ratings
      end

    end

  end

end
