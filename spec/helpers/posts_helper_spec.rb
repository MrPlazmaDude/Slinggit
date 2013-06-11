require 'spec_helper'

describe PostsHelper do

	let(:user) { FactoryGirl.create(:user) }
	let!(:post) { FactoryGirl.create(:post, user: user) }

	let(:twitter_api_account_primary) {FactoryGirl.create(:api_account, user_id: user.id, api_source: 'twitter')}
	let(:facebook_api_account_primary) {FactoryGirl.create(:api_account, user_id: user.id, api_source: 'facebook')}

	let(:twitter_api_account_secondary1) {FactoryGirl.create(:api_account, user_id: user.id, api_source: 'twitter', status: STATUS_ACTIVE)}
	let(:facebook_api_account_secondary1) {FactoryGirl.create(:api_account, user_id: user.id, api_source: 'facebook', status: STATUS_ACTIVE)}

	let(:twitter_api_account_secondary2) {FactoryGirl.create(:api_account, user_id: user.id, api_source: 'twitter', status: STATUS_ACTIVE)}
	let(:facebook_api_account_secondary2) {FactoryGirl.create(:api_account, user_id: user.id, api_source: 'facebook', status: STATUS_ACTIVE)}

	let(:twitter_post_primary) { FactoryGirl.create(:twitter_post, post: post, api_account: twitter_api_account_primary, user_id: user.id, status: STATUS_SUCCESS) }
	let(:twitter_post_secondary1) { FactoryGirl.create(:twitter_post, post: post, api_account: twitter_api_account_secondary1, user_id: user.id, status: STATUS_SUCCESS) }
	let(:twitter_post_secondary2) { FactoryGirl.create(:twitter_post, post: post, api_account: twitter_api_account_secondary2, user_id: user.id, status: STATUS_FAILED) }

	let(:facebook_post_primary) { FactoryGirl.create(:facebook_post, post: post, api_account: facebook_api_account_primary, user_id: user.id, status: STATUS_SUCCESS) }
	let(:facebook_post_secondary1) { FactoryGirl.create(:facebook_post, post: post, api_account: facebook_api_account_secondary1, user_id: user.id, status: STATUS_SUCCESS) }
	let(:facebook_post_secondary2) { FactoryGirl.create(:facebook_post, post: post, api_account: facebook_api_account_secondary2, user_id: user.id, status: STATUS_FAILED) }

	# Twitter posts
	it "should get primary twitter account" do
		helper.get_post_link(post, [twitter_post_primary, twitter_post_secondary1], 'twitter').should == twitter_post_primary
	end

	it "should get secondary, no primary used, iterates over fail twitter2" do
		helper.get_post_link(post, [twitter_post_secondary2, twitter_post_secondary1], 'twitter').should == twitter_post_secondary1
	end

	it "should return nil because no twitter post exist for this post" do
		helper.get_post_link(post, [], 'twitter').should be_nil
	end

	it "should return nil because the twitter post failed" do
		helper.get_post_link(post, [twitter_post_secondary2], 'twitter').should be_nil
	end

	# Facebook posts
	it "should get primary facebook account" do
		helper.get_post_link(post, [facebook_post_primary, facebook_post_secondary1], 'facebook').should == facebook_post_primary
	end

	it "should get secondary, no primary used, iterates over fail facebook2" do
		helper.get_post_link(post, [facebook_post_secondary2, facebook_post_secondary1], 'facebook').should == facebook_post_secondary1
	end

	it "should return nil because no facebook post exist for this post" do
		helper.get_post_link(post, [], 'facebook').should be_nil
	end

	it "should return nil because the facebook post failed" do
		helper.get_post_link(post, [facebook_post_secondary2], 'facebook').should be_nil
	end
	
end