require 'spec_helper'

describe FacebookPost do 

	let(:user) { FactoryGirl.create(:user) }
	let!(:post) { FactoryGirl.create(:post, user: user) }
	let(:api_account) {FactoryGirl.create(:api_account, user_id: user.id, api_source: 'facebook')}
	let(:facebook_post) { FactoryGirl.create(:facebook_post, post: post, api_account: api_account, user_id: user.id) }

	subject {facebook_post}

	its(:post) {should == post}
	its(:api_account) {should == api_account}
	its(:user_id) {should == user.id}

	it {should be_valid}

	describe "link to post" do
		its(:link_to_post) {should == "https://www.facebook.com/#{api_account.user_name}/posts/#{facebook_post.facebook_post_id.to_s.split("_")[1]}"}
	end

	describe "is primary account" do
		its(:primary_account) {should_not be_blank}
	end

end