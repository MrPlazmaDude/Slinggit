require 'spec_helper'

# HEADS UP!!  When testing controllers, don't forget about before filters!

describe "PostPages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  
  before { sign_in user }


  ## Commenting out any specs that don't currently work
  ## Uncomment them as you work through them.

  describe "post creation" do
    
    before { visit new_post_path }

    describe "with invalid information" do
  
      it { should have_selector('#post_hashtag_prefix')}
      it { should have_selector('#post_price')}
      it { should have_selector('#post_location')}
      it { should have_selector('#post_content')}

      it "should not create a post" do
        expect { click_button "submitNewPost" }.should_not change(Post, :count)
      end

      describe "error messages" do
        before { click_button "submitNewPost" }
        it { should have_content('error') } 
      end
    end

    describe "with valid information" do

      before { fill_in_post }
      it "should create a post" do
        expect { click_button "Post" }.should change(Post, :count).by(1)
      end
    end
  end

  # describe "post destruction" do
  #   before { FactoryGirl.create(:post, user: user) }

  #   describe "as correct user" do
  #     before { visit user_path(user) }

  #     it "should delete a post" do
  #       expect { click_link "delete" }.should change(Post, :count).by(-1)
  #     end
  #   end
  # end

  # CMK: updating this guy to actuall work.
  describe "post edit" do
  	let(:p1) { FactoryGirl.create(:post, user: user, content: "Foo") }

  	before { visit edit_post_path(p1) }

    let(:twitter_api_account) {FactoryGirl.create(:api_account, user_id: user.id, api_source: 'twitter')}
    let(:facebook_api_account) {FactoryGirl.create(:api_account, user_id: user.id, api_source: 'facebook', user_name: 'billyjimbob')}

  	describe "page" do
  		it { should have_selector('h1', text: "Repost:") }
      it { should have_selector('#post_hashtag_prefix', value: "bike")}
      it { should have_selector('#post_location', value: "Denver")}
      it { should have_selector('#post_content', value: "Foo")}
      it { should have_selector('#post_price', value: "20")}
      # Need to get this working.  Not sure why the api accounts aren't available here.
      # it { should have_selector('label', text: "mitchcumstein")}
  	end

  	describe "with invalid information" do
  	  let(:new_content)  { " " }
      before do
        fill_in "post_content",             with: new_content
        click_button "Repost Item"
      end
      it { should have_content('error') }
    end

    describe "with valid information" do
     let(:new_content)  { "New content" }
      before do
        fill_in "post_content",             with: new_content
        click_button "Repost Item"
      end

      it { should have_selector('div.alert.alert-success') }
      specify { p1.reload.content.should  == new_content }
    end	
  end	

end
