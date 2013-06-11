class UserMailer < ActionMailer::Base
  default from: "Slinggit <noreply@slinggit.com>"

  EXECUTIVES = 'danlogan@slinggit.com,chrisklein@slinggit.com,philbeadle@slinggit.com,chasecourington@slinggit.com'

  def welcome_email(user)
    @user = user
    @url = "#{BASEURL}/users/verify_email/#{user.email_activation_code}"
    mail(:to => user.email, :bcc => EXECUTIVES, :subject => "Welcome to Slinggit")
  end

  def api_account_post_failure(api_account)
    @user = User.first(:conditions => ['id = ?', api_account.user_id], :select => ['email,name'])
    @api_account = api_account
    mail(:to => @user.email, :subject => "Trouble posting to your #{api_account.api_source.titleize} account")
  end

  def password_reset(user)
    @user = user
    mail(:to => user.email, :subject => "Password reset for Slinggit.com")
  end

  def problem_report(problem_report)
    @problem_report = problem_report
    mail(:to => EXECUTIVES, :from => 'Problem Report <problem_report@slinggit.com>', :subject => "Problem Report - #{problem_report.exception_message}")
  end

  def terms_violation_notification(user, violation_reason)
    @user = user
    @violation_reason = violation_reason
    mail(:to => user.email, :subject => "Your account has been suspended")
  end

  def account_deleted(user)
    @user = user
    @reactive_url = "#{BASEURL}/users/reactivate/#{user.account_reactivation_code}"
    mail(:to => user.email, :subject => "Your account has been deleted")
  end

  def inform_admin_account_deleted(user)
    @user = user
    @user_feedbacks = UserFeedback.all(:conditions => ['user_id = ?', user.id])
    @reactive_url = "#{BASEURL}/users/reactivate/#{user.account_reactivation_code}"
    mail(:to => EXECUTIVES, :from => 'From Beyond The Grave <deleted_account@slinggit.com>', :subject => "User deleted account")
  end

  def invitation_request(email)
    mail(:to => email, :subject => "We have received your invitation request", :bcc => EXECUTIVES)
  end

  def invitation_approved(invitation)
    @activation_code = invitation.activation_code
    mail(:to => invitation.email, :subject => "Slinggit invitation approved", :bcc => EXECUTIVES)
  end

  def new_message(message)
    @message_object = message
    @recipient_user = User.first(:conditions => ['id = ?', message.recipient_user_id], :select => 'email,name')
    if not @recipient_user.blank?
      mail(:to => @recipient_user.email, :subject => "You have a new message")
    end
  end

  def flagged_content_notification(flagged_content)
    @flagged_content = flagged_content
    mail(:to => EXECUTIVES, :subject => "Content has been flagged")
  end

  def generic_internal_email(to, from, subject, content, reply_to = nil)
    @content = content.html_safe
    mail(:to => to, :from => from, :reply_to => reply_to, :subject => subject)
  end

  def post_monitor_report(posts_closed)
    @posts_closed = posts_closed
    mail(:to => EXECUTIVES, :from => 'Post Monitor <reports@slinggit.com>', :subject => "Daily post monitor report")
  end

  def comment_notifier(user_id, todays_comments)
    if user = User.first(:conditions => ['id = ?', user_id], :select => 'email,id')
      @todays_comments = todays_comments
      mail(:to => user.email, :subject => "Daily comment digest")
    end
  end

end
