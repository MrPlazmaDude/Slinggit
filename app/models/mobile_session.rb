# == Schema Information
#
# Table name: mobile_sessions
#
#  id                :integer         not null, primary key
#  user_id           :integer
#  unique_identifier :string(255)
#  mobile_auth_token :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  device_name       :string(255)
#  ip_address        :string(255)
#  options           :string(1000)
#

class MobileSession < ActiveRecord::Base
  attr_accessible :user_id, :unique_identifier, :mobile_auth_token, :device_name, :ip_address, :options
end
