# == Schema Information
#
# Table name: facebook_posts
#
#  id               :integer         not null, primary key
#  user_id          :integer
#  api_account_id   :integer
#  post_id          :integer
#  name             :string(255)
#  message          :string(255)
#  caption          :string(255)
#  description      :string(255)
#  image_url        :string(255)
#  link_url         :string(255)
#  facebook_post_id :string(255)
#  status           :string(255)
#  last_result      :string(255)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

class FacebookPost < ActiveRecord::Base
  attr_accessible :user_id, :api_account_id, :post_id, :name, :message, :caption, :description, :image_url, :link_url, :facebook_post_id, :status, :last_result
  belongs_to :api_account
  belongs_to :post

  SUCCESS_LAST_RESULT = 'successful post'
  SUCCESS_REPOST_LAST_RESULT = 'successful - duplicate post not submitted again'
  SUCCESS_NEVER_POSTED = 'successful - post was never on facebook'
  SUCCESS_UNDO_POST = 'successful - removed post from facebook'

  def do_post
    @start_time = Time.now
    self.update_attribute(:status, STATUS_PROCESSING)
    if not has_been_posted?
      if not self.api_account.blank?
        if not self.api_account.status == STATUS_DELETED
          begin
            response = post_constructor
            result = ActiveSupport::JSON.decode(response.body)
            if result['id']
              finalize(STATUS_SUCCESS, {:last_result => SUCCESS_LAST_RESULT, :facebook_post_id => result['id']}) and return
            else
              send_problem_report_no_execption result.to_s
              finalize(STATUS_FAILED, {:last_result => result.to_s}) and return
            end
          rescue Exception => e
            send_problem_report e
            finalize(STATUS_FAILED, {:last_result => "caught exception // #{e.class.to_s}-#{e.to_s}"}) and return
          end
        else
          send_problem_report_no_execption "api account has been deleted"
          finalize(STATUS_FAILED, {:last_result => "api account has been deleted"}) and return
        end
      else
        send_problem_report_no_execption "api_account_id does not exist"
        finalize(STATUS_FAILED, {:last_result => "api_account_id does not exist"}) and return
      end
    else
      finalize(STATUS_SUCCESS, {:last_result => SUCCESS_REPOST_LAST_RESULT}) and return
    end
  end

  def undo_post
    @start_time = Time.now
    self.update_attribute(:status, STATUS_PROCESSING)
    if has_been_posted?
      if not self.api_account.blank?
        begin
          uri = URI.parse "https://graph.facebook.com/#{self.facebook_post_id}?access_token=#{self.api_account.oauth_secret}"
          http = Net::HTTP.new(uri.host, uri.port)
          if uri.port == 443
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          return http.delete(uri.path, URI.escape(param_string))
          finalize(STATUS_SUCCESS, {:last_result => SUCCESS_UNDO_POST, :facebook_post_id => nil}) and return
        rescue Exception => e
          send_problem_report e
          finalize(STATUS_FAILED, {:last_result => "deleting_post // caught exception // #{e.class.to_s}-#{e.to_s}"}) and return
        end
      else
        send_problem_report_no_execption "deleting_post // api_account_id does not exist"
        finalize(STATUS_FAILED, {:last_result => "deleting_post // api_account_id does not exist"}) and return
      end
    else
      finalize(STATUS_SUCCESS, {:last_result => SUCCESS_NEVER_POSTED}) and return
    end
  end

  def finalize(status, options = {})
    self.last_result = options[:last_result] + " // dur=#{Time.now - @start_time}-sec"
    self.status = status
    self.facebook_post_id = options[:facebook_post_id]
    if options[:api_account_reauth_required]
      self.api_account.reauth_required = options[:api_account_reauth_required]
      UserMailer.api_account_post_failure(self.api_account).deliver
    end
    self.save
  end

  def has_been_posted?
    if not self.facebook_post_id.blank? or self.status == STATUS_DELETED
      return true
    else
      return false
    end
  end

# Logic for constructing facebook message.
  def post_constructor
    redirect_url = self.link_url
    if redirect_url.blank?
      redirect_url = "#{BASEURL}/posts/#{self.post.id}"
    end

    redirect = Redirect.get_or_create(
        :target_uri => "#{redirect_url}"
    )

    uri = URI.parse "https://graph.facebook.com/#{self.api_account.api_id}/feed"
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.port == 443
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    access_token = self.api_account.oauth_secret
    link_to_post = redirect.get_short_url
    name = self.name
    message = self.message
    description = self.description
    caption = self.caption

    param_string = "access_token=#{access_token}&link=#{link_to_post}&name=#{name}&message=#{message}&description=#{description}&caption=#{caption}"
    if self.post.has_photo?
      param_string << "&picture=#{BASEURL}#{post.photo.url(:medium)}"
    end
    return http.post(uri.path, URI.escape(param_string))
  end

  def link_to_post
    facebook_account = ApiAccount.first(:conditions => ['id = ?', self.api_account_id], :select => 'user_name')
    # Because a user could delete a facebook account after they've posted a link, we should check for nil, even
    # though we don't actually delete it, we just change the status
    if not facebook_account.blank? 
      delims = self.facebook_post_id.to_s.split("_")
      facebook_truncated_id = delims[1]
      return "https://www.facebook.com/#{facebook_account.user_name}/posts/#{facebook_truncated_id}"
    else
      return nil
    end 
  end

  def primary_account
    facebook_account = ApiAccount.first(:conditions => ['id = ?', self.api_account_id], :select => 'status')
  end

  # Problem reports
  def send_problem_report exception
    ProblemReport.create(
        :exception_message => exception.message,
        :exception_class => exception.class.to_s,
        :exception_backtrace => exception.backtrace,
        :signed_in_user_id => self.user_id != nil ? self.user_id : nil,
        :send_email => true
    )
  end

  def send_problem_report_no_execption str
    ProblemReport.create(
        :exception_message => str,
        :signed_in_user_id => self.user_id != nil ? self.user_id : nil,
        :send_email => true
    )
  end

end
