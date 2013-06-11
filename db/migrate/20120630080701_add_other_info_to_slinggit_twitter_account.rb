class AddOtherInfoToSlinggitTwitterAccount < ActiveRecord::Migration
  def up
    if slinggit_twitter_api_account = ApiAccount.first(:conditions => ['user_id = ? AND user_name = ?', 0, Rails.configuration.slinggit_username], :select => 'id,real_name,image_url')
      slinggit_twitter_api_account.real_name = 'slinggit'
      slinggit_twitter_api_account.image_url = 'http://si0.twimg.com/profile_images/2327223633/fthph4wm3mkubb6mi7wi.png'
      slinggit_twitter_api_account.save
    end
  end

  def down
    if slinggit_twitter_api_account = ApiAccount.first(:conditions => ['user_id = ? AND user_name = ?', 0, Rails.configuration.slinggit_username], :select => 'id,real_name,image_url')
      slinggit_twitter_api_account.real_name = nil
      slinggit_twitter_api_account.image_url = nil
      slinggit_twitter_api_account.save
    end
  end
end
