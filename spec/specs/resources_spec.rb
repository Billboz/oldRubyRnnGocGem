require 'spec_helper'

describe Goc do
  let(:user) { FactoryGirl.create(:user) }
  let(:domain) { Domain.find_by_name "comments" }
  let(:noob_badge) { Badge.find_by_name "noob" }
  let(:medium_badge) { Badge.find_by_name "medium" }

  context "Get a new resource and add and remove ratings to it" do

    it "should have nil as value of ratings" do
      user.ratings.should == []
    end

    context "Incressing ratings to an user win noob badge of domain comment" do

      it "Add the noob badge and the ratings related to an user" do
        user.change_points(ratings: noob_badge.ratings, domain: domain.id)
        user.reload
        user.badges.should include noob_badge
        user.ratings.where(:kind_id => domain.id).sum(:value) == noob_badge.ratings
      end

      it "Add ratings related to a user's domain, using single increases" do
        final_score = 4
        final_score.times do
          user.change_points(ratings: 1, domain: domain.id)
        end
        user.ratings.where(:kind_id => domain.id).sum(:value).should == final_score
      end

      it "Remove ratings related to a user's domain, using single decreases" do
        initial_score = 10
        final_score = 4
        user.change_points(ratings: initial_score, domain: domain.id)
        (initial_score - final_score).times do
          user.change_points(ratings: -1, domain: domain.id)
        end
        user.ratings.where(:kind_id => domain.id).sum(:value).should == final_score
      end
    end

    context "Decressing ratings to an user loose meidum badge" do

      before(:each) do
        user.change_points(ratings: medium_badge.ratings, domain: domain.id)
      end

      it "Remove the medium badge and the ratings related" do
        user.change_points(ratings: - medium_badge.ratings, domain: domain.id)
        user.reload
        user.badges.should_not include medium_badge
        user.ratings.where(:kind_id => domain.id).sum(:value) == 0
      end
    end
  end

  context "Getting resource data related with next badge" do

    it "should return a hash with the info for the noob_badge" do
      user.next_badge?(domain.id).should == { :badge=> noob_badge,
                                            :ratings=> noob_badge.ratings,
                                            :percentage=> 0
                                          }
    end

    it "should return a hash with the info for the medium_badge" do
      noob_badge.add user.id
      user.next_badge?(domain.id).should == { :badge=> medium_badge,
                                            :ratings=> medium_badge.ratings - user.ratings.sum(:value),
                                            :percentage=>(user.ratings.sum(:value) - user.badges.last.ratings)*100/(medium_badge.ratings - user.badges.last.ratings)
                                          }
    end
  end
end
