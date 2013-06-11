require 'spec_helper'

describe TwitterPost do 

	let(:user) { FactoryGirl.create(:user) }
	let!(:post) { FactoryGirl.create(:post, user: user) }
	let(:api_account) {FactoryGirl.create(:api_account, user_id: user.id)}
	let(:twitter_post) { FactoryGirl.create(:twitter_post, post: post, api_account: api_account, user_id: user.id) }

	subject { twitter_post }

	# since a twitter post cannot be created without a post, an api_account and a user
	# I'm checking for them here.
	its(:post) {should == post}
	its(:api_account) {should == api_account}
	its(:user_id) {should == user.id}

	it {should be_valid}

	describe "link to post" do
		its(:link_to_post) {should == "https://twitter.com/#!/#{api_account.user_name}/status/#{twitter_post.twitter_post_id}"}
	end

	describe "is primary account" do
		its(:primary_account) {should_not be_blank}
	end
	
end