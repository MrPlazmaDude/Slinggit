# == Schema Information
#
# Table name: problem_reports
#
#  id                      :integer         not null, primary key
#  exception_message       :string(255)
#  exception_class         :string(255)
#  exception_backtrace     :text
#  user_agent              :string(255)
#  ip_address              :string(255)
#  url_referrer            :string(255)
#  signed_in_user_id       :integer
#  status                  :string(255)     default("open")
#  last_updated_by_user_id :integer
#  owned_by_user_id        :integer
#  created_at              :datetime        not null
#  updated_at              :datetime        not null
#

#create_table :problem_reports do |t|
#  t.string :exception_message
#  t.string :exception_class
#  t.text :exception_backtrace
#  t.string :user_agent
#  t.string :ip_address
#  t.string :url_referrer
#  t.integer :signed_in_user_id
#  t.string :status, :default => 'open'
#  t.integer :last_updated_by_user_id
#  t.integer :owned_by_user_id
#  t.timestamps
#end

class ProblemReport < ActiveRecord::Base
  #not a column we need but we might not always want to send an email
  attr_accessor :send_email

  attr_accessible :exception_message, :exception_class, :exception_backtrace, :user_agent, :ip_address, :url_referrer, :signed_in_user_id, :status, :send_email

  after_create :send_problem_report_email

  def send_problem_report_email
    if send_email
      UserMailer.problem_report(self).deliver
    end
  end

  def owner_name
    if not self.owned_by_user_id.blank?
      return User.first(:conditions => ['id = ?', self.owned_by_user_id], :select => 'name').name
    else
      return 'system'
    end
  end

  def last_updated_by_name
    if not self.last_updated_by_user_id.blank?
      return User.first(:conditions => ['id = ?', self.last_updated_by_user_id], :select => 'name').name
    else
      return 'system'
    end
  end

  def signed_in_user_name
    if not self.signed_in_user_id.blank?
      return User.first(:conditions => ['id = ?', self.signed_in_user_id], :select => 'name').name
    else
      return 'No one was logged in'
    end
  end

end


