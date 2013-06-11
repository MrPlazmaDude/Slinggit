# == Schema Information
#
# Table name: api_accounts
#
#  id               :integer         not null, primary key
#  user_id          :integer
#  api_id           :string(255)
#  api_id_hash      :string(255)
#  api_source       :string(255)
#  oauth_token      :string(255)
#  oauth_secret     :string(255)
#  real_name        :string(255)
#  user_name        :string(255)
#  image_url        :string(255)
#  description      :string(255)
#  language         :string(255)
#  location         :string(255)
#  status           :string(255)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  reauth_required  :string(255)     default("no")
#  oauth_expiration :datetime
#

class ApiAccount < ActiveRecord::Base
  before_create :create_api_id_hash
  attr_accessible :user_id, :api_id, :api_source, :oauth_token, :oauth_secret, :real_name, :user_name, :image_url, :description, :language, :location, :status, :reauth_required, :oauth_expiration

  private

  def create_api_id_hash
    self.api_id_hash = Digest::SHA1.hexdigest(self.api_id.to_s)
  end

end
