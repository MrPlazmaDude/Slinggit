# == Schema Information
#
# Table name: user_logins
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  user_agent      :string(255)
#  ip_address      :string(255)
#  url_referrer    :string(255)
#  login_source    :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  session_json    :string(500)
#  paramaters_json :string(500)
#

class UserLogin < ActiveRecord::Base
  attr_accessible :user_id, :user_agent, :ip_address, :url_referrer, :login_source, :session_json, :paramaters_json
end
