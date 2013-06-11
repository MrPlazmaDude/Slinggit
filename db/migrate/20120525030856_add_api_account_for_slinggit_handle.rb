class AddApiAccountForSlinggitHandle < ActiveRecord::Migration
  def up
  	ApiAccount.create :user_id => 0,
		              :api_source => 'twitter',
		              :oauth_token => Rails.configuration.slinggit_client_atoken,
		              :oauth_secret => Rails.configuration.slinggit_client_asecret,
		              :user_name => Rails.configuration.slinggit_username,
		              :language => "en",
		              :reauth_required => 'no',
		              :status => 'active'
  end

  def down
  	apiAccount = ApiAccount.first(:conditions => ['user_id = ? AND user_name = ?', 0, Rails.configuration.slinggit_username])
  	apiAccount.destroy if not apiAccount.blank?
  end
end
