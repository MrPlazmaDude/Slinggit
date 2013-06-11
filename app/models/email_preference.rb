#create_table :email_preferences do |t|
#  t.integer :user_id
#  t.boolean :system_emails
#  t.boolean :marketing_emails


class EmailPreference < ActiveRecord::Base
  attr_accessible :user_id, :system_emails, :marketing_emails
end
