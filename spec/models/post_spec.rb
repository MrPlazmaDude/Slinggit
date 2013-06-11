# == Schema Information
#
# Table name: posts
#
#  id                        :integer         not null, primary key
#  content                   :string(255)
#  user_id                   :integer
#  created_at                :datetime        not null
#  updated_at                :datetime        not null
#  photo_file_name           :string(255)
#  photo_content_type        :string(255)
#  photo_file_size           :integer
#  photo_updated_at          :datetime
#  hashtag_prefix            :string(255)
#  price                     :integer(8)
#  open                      :boolean         default(TRUE)
#  location                  :string(255)
#  recipient_api_account_ids :string(255)
#  status                    :string(255)     default("ACT")
#  id_hash                   :string(255)
#

require 'spec_helper'

describe Post do

  let(:user) { FactoryGirl.create(:user) }
  before { @post = user.posts.build(content: "Lorem ipsum", hashtag_prefix: "bike", price: '20') }

  subject { @post }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  its(:user) { should == user }

  it { should be_valid }

  describe "when user_id is not present" do
    before { @post.user_id = nil }
    it { should_not be_valid }
  end

  describe "accessible attributes" do
    # it "should not allow access to user_id" do
    #   expect do
    #     Post.new(user_id: user.id)
    #   end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    # end    
  end

  describe "with blank content" do
    before { @post.content = " " }
    it { should_not be_valid }
  end

    describe "with blank price" do
    before { @post.price = " " }
    it { should_not be_valid }
  end

  describe "with content that is too long" do
    before { @post.content = "a" * 301 }
    it { should_not be_valid }
  end

end
