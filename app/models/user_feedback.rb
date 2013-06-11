# == Schema Information
#
# Table name: user_feedbacks
#
#  id          :integer         not null, primary key
#  user_id     :integer
#  source      :string(255)
#  information :text
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

#create_table :user_feedbacks do |t|
#  t.integer :user_id
#  t.string :source
#  t.text :information
#  t.timestamps
#end

class UserFeedback < ActiveRecord::Base
  attr_accessible :user_id, :source, :information
end
