# == Schema Information
#
# Table name: invitations
#
#  id              :integer         not null, primary key
#  email           :string(255)
#  comment         :text
#  status          :string(255)     default("pending")
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  source_user_id  :integer
#  activation_code :string(255)
#

#create_table :invitations do |t|
#  t.string :email_address
#  t.text :comment
#  t.string :status, :default => 'pending'
#t.timestamps
#end

class Invitation < ActiveRecord::Base
  attr_accessible :email, :comment, :status, :activation_code

  after_create :send_invitation_email

  def is_active?
    self.status == 'active'
  end

  def send_invitation_email
    UserMailer.invitation_request(self.email).deliver
  end
end
