# == Schema Information
#
# Table name: user_limitations
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  limitation_type :string(255)
#  user_limit      :integer
#  frequency       :integer
#  frequency_type  :string(255)
#  active          :boolean         default(TRUE)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

class UserLimitation < ActiveRecord::Base
  attr_accessible :user_id, :limitation_type, :user_limit, :frequency, :frequency_type, :active
end
