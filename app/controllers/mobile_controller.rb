class MobileController < ApplicationController
  include Rack::Utils

  #filter chain halts with friendly error message for accounts not in good standing
  before_filter :halt_if_banned, :except => [:halt_if_suspended, :user_signup, :user_login, :user_logout, :user_login_status]
  before_filter :halt_if_suspended_or_unverified, :only => [:add_twitter_account, :add_facebook_account, :create_post, :resubmit_to_post_recipients, :create_post_comment, :send_message, :reply_to_message, :report_abuse, :add_post_to_watch_list]

  #regular before filters for good standing accounts
  before_filter :set_source
  before_filter :require_post, :except => [:add_twitter_account_callback, :finalize_add_twitter_account, :add_facebook_account_callback, :finalize_add_facebook_account]
  before_filter :validate_user_agent, :except => [:add_twitter_account, :add_twitter_account_callback, :finalize_add_twitter_account, :add_facebook_account, :add_facebook_account_callback, :finalize_add_facebook_account]
  before_filter :validate_request_authenticity, :except => [:add_twitter_account_callback, :finalize_add_twitter_account, :add_facebook_account_callback, :finalize_add_facebook_account]
  before_filter :set_state, :except => [:add_twitter_account_callback, :finalize_add_twitter_account, :add_facebook_account_callback, :finalize_add_facebook_account]
  before_filter :set_device_name, :except => [:add_twitter_account_callback, :finalize_add_twitter_account, :add_facebook_account_callback, :finalize_add_facebook_account]
  before_filter :set_mobile_auth_token, :except => [:user_signup, :user_login, :add_twitter_account, :add_twitter_account_callback, :finalize_add_twitter_account, :add_facebook_account, :add_facebook_account_callback, :finalize_add_facebook_account, :password_reset]
  before_filter :set_options, :except => [:add_twitter_account_callback, :finalize_add_twitter_account, :add_facebook_account_callback, :finalize_add_facebook_account]
  around_filter :catch_exceptions

  ERROR_STATUS = 'error'
  SUCCESS_STATUS = 'success'
  NATIVE_APP = 'native_app'
  NATIVE_APP_WEB_VIEW = 'native_app_web_view'
  MOBILE_VIEW_ACTIONS = [:add_twitter_account, :add_twitter_account_callback, :finalize_add_twitter_account]
  PLACEHOLDER_IMAGE_STYLES = ['80x80_placeholder', '300x300_placeholder', 'noPhoto_80x80', 'noPhoto_300x300']

  def user_signup
    if not params[:user_name].blank?
      if not params[:email].blank?
        if not params[:password].blank?
          user_name = params[:user_name].downcase
          email = params[:email].downcase
          if not User.exists?(['email = ?', email])
            if not User.exists?(['name = ?', user_name])
              user = User.new(
                  :name => params[:user_name],
                  :email => params[:email],
                  :password => params[:password],
                  :password_confirmation => params[:password]
              )

              if user.save
                log_user_login(user)
                mobile_auth_token = create_or_update_mobile_auth_token(user.id)
                if not params[:access_token].blank? and not params[:access_token_secret].blank?
                  client = Twitter::Client.new(oauth_token: params[:access_token], oauth_token_secret: params[:access_token_secret])
                  create_api_account(:source => :twitter, :user_object => user, :api_object => client)
                end
                render_success_response(
                    :mobile_auth_token => mobile_auth_token,
                    :user_id => user.id
                )
              else
                render_error_response(
                    :error_location => 'user_signup',
                    :error_reason => 'invalid - email',
                    :error_code => '409',
                    :friendly_error => 'The email address entered is invalid.'
                )
              end
            else
              render_error_response(
                  :error_location => 'user_signup',
                  :error_reason => 'unavailable - user_name',
                  :error_code => '409',
                  :friendly_error => 'That Username has already been registered.'
              )
            end
          else
            render_error_response(
                :error_location => 'user_signup',
                :error_reason => 'unavailable - email',
                :error_code => '409',
                :friendly_error => 'That email address has already been registered.'
            )
          end
        else
          render_error_response(
              :error_location => 'user_signup',
              :error_reason => 'missing required_paramater - password',
              :error_code => '403',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'user_signup',
            :error_reason => 'missing required_paramater - email',
            :error_code => '403',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'user_signup',
          :error_reason => 'missing required_paramater - user_name',
          :error_code => '403',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def user_login
    if not params[:email].blank?
      if not params[:password].blank?
        user = User.first(:conditions => ["email = '#{params[:email]}'"])
        if user && user.authenticate(params[:password])
          log_user_login(user)
          mobile_auth_token = create_or_update_mobile_auth_token(user.id)
          render_success_response(
              :mobile_auth_token => mobile_auth_token,
              :user_name => user.name,
              :user_id => user.id
          )
        else
          render_error_response(
              :error_location => 'user_login',
              :error_reason => 'password authentication failed',
              :error_code => '403',
              :friendly_error => 'Incorrect email and or password.'
          )
        end
      else
        render_error_response(
            :error_location => 'user_login',
            :error_reason => 'missing required_paramater - password',
            :error_code => '403',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'user_login',
          :error_reason => 'missing required_paramater - email',
          :error_code => '403',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def user_logout
    if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'id,mobile_auth_token')
      mobile_session.update_attribute(:mobile_auth_token, nil)
      render_success_response(
          :logged_in => false
      )
    else
      render_error_response(
          :error_location => 'user_logout',
          :error_reason => 'not found - mobile_session',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def user_login_status
    if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token])
      user = User.first(:conditions => ['id = ?', mobile_session.user_id], :select => 'name,id')
      render_success_response(
          :logged_in => true,
          :user_name => user.name,
          :user_id => user.id
      )
    else
      render_success_response(
          :logged_in => false
      )
    end
  end

  def delete_twitter_account
    if not params[:api_account_id].blank?
      if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token])
        if api_account = ApiAccount.first(:conditions => ['id = ? AND user_id = ?', params[:api_account_id], mobile_session.user_id])
          if not api_account.status == STATUS_DELETED
            success, result = delete_api_account(api_account)
            if success
              render_success_response(
                  :api_account_id => api_account.id,
                  :api_account_status => api_account.status,
                  :new_primary_api_account_id => result.blank? ? '' : result.id,
                  :new_primary_api_account_status => result.blank? ? '' : result.status
              )
            else
              render_error_response(
                  :error_location => 'delete_twitter_account',
                  :error_reason => result,
                  :error_code => '404',
                  :friendly_error => 'Oops, something went wrong.  Please try again later.'
              )
            end
          else
            render_success_response(
                :api_account_id => api_account.id,
                :api_account_status => api_account.status,
                :note => 'this api account had already been deleted.  There may be a problem with your code.'
            )
          end
        else
          render_error_response(
              :error_location => 'delete_twitter_account',
              :error_reason => 'api account not found',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'delete_twitter_account',
            :error_reason => 'mobile session not found',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'delete_twitter_account',
          :error_reason => 'missing required_paramater - api_account_id',
          :error_code => '403',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def add_post_to_watch_list
    post_id = params[:post_id]
    if not post_id.blank?
      if Post.exists?(['id = ?', post_id])
        if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'user_id')
          if user = User.first(:conditions => ['id = ?', mobile_session.user_id], :select => ['id'])
            watchedpost = nil
            if not user.post_in_watch_list?(post_id)
              add_to_watchedposts(user, post_id)
            end

            render_success_response()


          else
            render_error_response(
                :error_location => 'add_post_to_watch_list',
                :error_reason => 'not found - user',
                :error_code => '404',
                :friendly_error => 'Oops, something went wrong.  Please try again later.'
            )
          end
        else
          render_error_response(
              :error_location => 'add_post_to_watch_list',
              :error_reason => 'mobile session not found',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'add_post_to_watch_list',
            :error_reason => 'not found - post',
            :error_code => '403',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'add_post_to_watch_list',
          :error_reason => 'missing required_paramater - post_id',
          :error_code => '403',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def remove_post_from_watch_list
    post_id = params[:post_id]
    if not post_id.blank?
      if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'user_id')
        if user = User.first(:conditions => ['id = ?', mobile_session.user_id], :select => ['id'])
          watchedpost = user.watchedposts.first(:conditions => ['user_id = ? AND post_id = ?', user.id, post_id])
          if not watchedpost.blank?
            watchedpost.destroy
          end

          render_success_response()

        else
          render_error_response(
              :error_location => 'remove_post_from_watch_list',
              :error_reason => 'not found - user',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'remove_post_from_watch_list',
            :error_reason => 'not found - post',
            :error_code => '403',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'remove_post_from_watch_list',
          :error_reason => 'missing required_paramater - post_id',
          :error_code => '403',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def add_twitter_account
    setup_twitter_call(url_for :controller => :mobile, :action => :add_twitter_account_callback, :user_name => params[:user_name])
  end

  def add_facebook_account
    setup_facebook_call(url_for(:controller => :mobile, :action => :add_facebook_account_callback, :user_name => params[:user_name]), 'publish_stream')
  end

  def add_twitter_account_callback
    rtoken = session['rtoken']
    rsecret = session['rsecret']
    if not params[:denied].blank?
      redirect_to :controller => :mobile, :action => :finalize_add_twitter_account, :result_status => ERROR_STATUS, :friendly_error => 'You can always add your Twitter account later!', :error_reason => 'user denied permission'
    else
      request_token = OAuth::RequestToken.new(oauth_consumer, rtoken, rsecret)
      access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
      if not params[:user_name].blank?
        if user = User.first(:conditions => ['name = ?', params[:user_name]])
          client = Twitter::Client.new(oauth_token: access_token.token, oauth_token_secret: access_token.secret)
          create_api_account(:source => :twitter, :user_object => user, :api_object => client)
          redirect_to :controller => :mobile, :action => :finalize_add_twitter_account, :result_status => SUCCESS_STATUS
        else
          redirect_to :controller => :mobile, :action => :finalize_add_twitter_account, :result_status => ERROR_STATUS, :friendly_error => 'Oops, something went wrong.  Please try again later.', :user_name => params[:user_name], :error_reason => 'user not found'
        end
      else
        redirect_to :controller => :mobile, :action => :finalize_add_twitter_account, :result_status => SUCCESS_STATUS, :access_token => access_token.token, :access_token_secret => access_token.secret
      end
    end
  end

  def add_facebook_account_callback
    if params[:error].blank?
      if not params[:code].blank? and not params[:state].blank?
        if params[:state] == Digest::SHA1.hexdigest(SLINGGIT_SECRET_HASH)
          redirect_uri = url_for :controller => :mobile, :action => :add_facebook_account_callback, :user_name => params[:user_name]
          access_token_url = URI.escape("https://graph.facebook.com/oauth/access_token?client_id=#{Rails.configuration.facebook_app_id}&redirect_uri=#{redirect_uri}&client_secret=#{Rails.configuration.facebook_app_secret}&code=#{params[:code]}")
          client = HTTPClient.new
          access_token_response = client.get_content(access_token_url)

          if not access_token_response.blank?
            if access_token_response.include? 'error'
              redirect_to :controller => :mobile, :action => :finalize_add_facebook_account, :result_status => ERROR_STATUS, :friendly_error => 'You can always add your Facebook account later!', :error_reason => 'User denied permission'
            else
              access_token_and_expiration = parse_nested_query(access_token_response)
              basic_user_info_response = client.get_content("https://graph.facebook.com/me?access_token=#{access_token_and_expiration['access_token']}")
              if not basic_user_info_response.blank?
                if user = User.first(:conditions => ['name = ?', params[:user_name]])
                  decoded_basic_user_info = ActiveSupport::JSON.decode(basic_user_info_response)
                  decoded_basic_user_info.merge!(access_token_and_expiration)
                  success, result = create_api_account(:source => :facebook, :user_object => user, :api_object => decoded_basic_user_info)
                  if success
                    redirect_to :controller => :mobile, :action => :finalize_add_facebook_account, :result_status => SUCCESS_STATUS
                  else
                    redirect_to :controller => :mobile, :action => :finalize_add_facebook_account, :result_status => ERROR_STATUS, :friendly_error => 'Oops, something went wrong.  Please try again later.', :error_reason => result
                  end
                else
                  redirect_to :controller => :mobile, :action => :finalize_add_facebook_account, :result_status => ERROR_STATUS, :friendly_error => 'Oops, something went wrong.  Please try again later.', :error_reason => "User object not found for given user_name"
                end
              else
                redirect_to :controller => :mobile, :action => :finalize_add_facebook_account, :result_status => ERROR_STATUS, :friendly_error => 'Oops, something went wrong.  Please try again later.', :error_reason => "Cant get user data"
              end
            end
          else
            redirect_to :controller => :mobile, :action => :finalize_add_facebook_account, :result_status => ERROR_STATUS, :friendly_error => 'Oops, something went wrong.  Please try again later.', :error_reason => "No access token response"
          end
        else
          redirect_to :controller => :mobile, :action => :finalize_add_facebook_account, :result_status => ERROR_STATUS, :friendly_error => "Uh oh, we couldn't verify the authenticity of your request.  Please try again later'.", :error_reason => "Request not authentic"
        end
      else
        redirect_to :controller => :mobile, :action => :finalize_add_facebook_account, :result_status => ERROR_STATUS, :friendly_error => 'Oops, something went wrong.  Please try again later.', :error_reason => "No code was passed back from Facebook"
      end
    else
      redirect_to :controller => :mobile, :action => :finalize_add_facebook_account, :result_status => ERROR_STATUS, :friendly_error => "In order to add your Facebook account, we need you to accept the permissions presented by Facebook.", :error_reason => "User denied permission"
    end
  end

  def finalize_add_twitter_account
    #This will never get hit because the mobile page view intercepts it and prevents it from redirecting here.
    #It is not necessary for this to contain an attached view or render any thing what so ever
    #It is however, necessary for this definition to be present for rails url_for routing purposes and so that we have a distinct url that
    #indicates to the mobile device that the call is over.
  end

  def finalize_add_facebook_account
    #This will never get hit because the mobile page view intercepts it and prevents it from redirecting here.
    #It is not necessary for this to contain an attached view or render any thing what so ever
    #It is however, necessary for this definition to be present for rails url_for routing purposes and so that we have a distinct url that
    #indicates to the mobile device that the call is over.
  end

  def create_post
    if not params[:hashtag_prefix].blank?
      if not params[:content].blank?
        if not params[:price].blank?
          if not params[:location].blank?
            if mobile_session = MobileSession.first(:conditions => ['mobile_auth_token = ?', @mobile_auth_token], :select => 'user_id')
              if user = User.first(:conditions => ['id = ?', mobile_session.user_id], :select => ['id'])

                tmp_file_path = get_temp_photo_path(params[:hashtag_prefix] + Time.now.to_f.to_s)
                if not params[:image_data].blank?
                  image_data = Base64.decode64(params[:image_data])
                  @file = File.open(tmp_file_path, 'wb') { |file| (file << image_data) }
                end

                post = Post.new(
                    :user_id => user.id,
                    :hashtag_prefix => params[:hashtag_prefix],
                    :content => params[:content],
                    :price => params[:price],
                    :location => params[:location],
                    :photo => @file
                )

                if post.has_photo?
                  File.delete(tmp_file_path)
                end

                if post.save
                  recipient_api_account_ids = []
                  if not params[:api_account_ids].blank?
                    params[:api_account_ids].split(',').each do |api_account_id|
                      if proposed_api_account = ApiAccount.first(:conditions => ['id = ?', api_account_id], :select => 'user_id,api_source')
                        if mobile_session.user_id == proposed_api_account.user_id || proposed_api_account.user_id == 0
                          recipient_api_account_ids << proposed_api_account.id
                          if proposed_api_account.api_source == 'twitter'
                            TwitterPost.create(
                                :user_id => post.user_id,
                                :api_account_id => api_account_id.to_i,
                                :post_id => post.id,
                                :content => post.content
                            ).do_post
                          elsif proposed_api_account.api_source == 'facebook'
                            FacebookPost.create(
                                :user_id => post.user_id,
                                :api_account_id => api_account_id.to_i,
                                :post_id => post.id,
                                :message => "For sale: ##{post.hashtag_prefix}",
                                :name => "$#{post.price}.00",
                                :caption => "Location: #{post.location}",
                                :description => post.content,
                                :image_url => post.has_photo? ? "#{BASEURL}#{post.root_url_path}" : nil,
                                :link_url => nil #if this is nil it will default to the post
                            ).do_post
                          end
                        end
                      end
                    end
                    if not recipient_api_account_ids.blank?
                      post.update_attribute(:recipient_api_account_ids, recipient_api_account_ids.join(','))
                    end
                  end

                  render_success_response(
                      :post_id => post.id,
                      :recipient_api_account_ids => recipient_api_account_ids
                  )
                else
                  if post.errors.messages.length > 0
                    error_field = post.errors.messages.first.first
                    error_reason = post.errors.messages.first.last.first
                    render_error_response(
                        :error_location => 'create_post',
                        :error_reason => "#{error_field} #{error_reason}",
                        :error_code => '403',
                        :friendly_error => 'Oops, something went wrong.  Please try again later.'
                    )
                  else
                    render_error_response(
                        :error_location => 'create_post',
                        :error_reason => "unknown error occured",
                        :error_code => '404',
                        :friendly_error => 'Oops, something went wrong.  Please try again later.'
                    )
                  end
                end
              else
                render_error_response(
                    :error_location => 'create_post',
                    :error_reason => 'user not found',
                    :error_code => '404',
                    :friendly_error => 'Oops, something went wrong.  Please try again later.'
                )
              end
            else
              render_error_response(
                  :error_location => 'create_post',
                  :error_reason => 'mobile session not found',
                  :error_code => '404',
                  :friendly_error => 'Oops, something went wrong.  Please try again later.'
              )
            end
          else
            render_error_response(
                :error_location => 'create_post',
                :error_reason => 'missing required_paramater - location',
                :error_code => '403',
                :friendly_error => 'Oops, something went wrong.  Please try again later.'
            )
          end
        else
          render_error_response(
              :error_location => 'create_post',
              :error_reason => 'missing required_paramater - price',
              :error_code => '403',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'create_post',
            :error_reason => 'missing required_paramater - content',
            :error_code => '403',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'create_post',
          :error_reason => 'missing required_paramater - hashtag_prefix',
          :error_code => '403',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def get_slinggit_post_data
    if not params[:offset].blank?
      if not params[:limit].blank?

        #offset can be 0
        offset = params[:offset].to_i
        offset = 0 if offset < 0

        #limit cannot be 0
        limit = params[:limit].to_i
        limit = 1 if limit <= 0

        #starting_post_id can come in as 0 or blank and needs to be set to the max + 1 if thats the case
        #always need to inc by 1
        starting_post_id = params[:starting_post_id]

        if (starting_post_id.blank? or starting_post_id.to_i <= 0)
          starting_post_id = Post.find_by_sql('select id from posts order by id desc limit 1')
          if not starting_post_id.blank?
            starting_post_id = starting_post_id.first.id + 1
          end
        end

        starting_post_id = 0 if starting_post_id.blank?
        starting_post_id = starting_post_id.to_i

        posts = []
        success = false
        result = {}

        filter_data = {
            :offset => offset,
            :limit => limit,
            :starting_post_id => starting_post_id,
            :search_term => params[:search_term],
            :user_name => params[:user_name]
        }

        if not filter_data[:user_name].blank?
          success, result = get_slinggit_post_data_for_user(filter_data)
        else
          success, result = get_all_slinggit_post_data(filter_data)
        end

        if success
          posts_array = []
          result.each do |post|
            posts_array << {
                :status => post.status,
                :post_id => post.id,
                :user_id => post.user_id,
                :open => post.open ? 'true' : 'false',
                :content => post.content,
                :hashtag_prefix => post.hashtag_prefix,
                :price => post.price.to_i,
                :location => post.location,
                :recipient_api_account_ids => post.recipient_api_account_ids.blank? ? '' : post.recipient_api_account_ids,
                :image_uri => post.has_photo? ? "#{BASEURL}/#{post.photo.url(:search)}" : nil,
                :created_at_date => post.created_at.strftime("%m-%d-%Y"),
                :created_at_time => post.created_at.strftime("%H:%M")
            }
          end

          return_data = {
              :rows_found => result.length.to_s,
              :filters_used => filter_data,
              :posts => posts_array
          }

          render_success_response(return_data)
        else
          render_error_response(result)
        end
      else
        render_error_response(
            :error_location => 'get_slinggit_post_data',
            :error_reason => 'missing required_paramater - limit',
            :error_code => '403',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'get_slinggit_post_data',
          :error_reason => 'missing required_paramater - offset',
          :error_code => '403',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def check_limitations
    if not params[:limitation_type].blank?
      if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token])
        user = User.first(:conditions => ['id = ?', mobile_session.user_id], :select => 'id')
        success, friendly_error_message = passes_limitations?(params[:limitation_type], user.id)
        if success
          render_success_response(
              :limitation_type => params[:limitation_type],
              :pass => true
          )
        else
          render_success_response(
              :limitation_type => params[:limitation_type],
              :pass => false,
              :friendly_error => friendly_error_message
          )
        end
      else
        render_error_response(
            :error_location => 'check_limitations',
            :error_reason => 'mobile session not found',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'user_login_status',
          :error_reason => 'missing required_paramater - limitation_type',
          :error_code => '403',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def resubmit_to_post_recipients
    if not params[:post_id].blank?
      if mobile_session = MobileSession.first(:conditions => ['mobile_auth_token = ?', @mobile_auth_token], :select => 'user_id')
        if user = User.first(:conditions => ['id = ?', mobile_session.user_id], :select => ['id'])
          if post = Post.first(:conditions => ['id = ? AND user_id = ? AND recipient_api_account_ids IS NOT NULL', params[:post_id], user.id], :select => 'recipient_api_account_ids,id')
            recipient_api_account_ids = post.recipient_api_account_ids.split(',')
            recipient_api_account_ids.each do |api_account_id|
              TwitterPost.create(
                  :user_id => user.id,
                  :api_account_id => api_account_id,
                  :post_id => post.id
              ).do_post
            end
            render_success_response(
                :resubmit_count => recipient_api_account_ids.length
            )
          else
            render_error_response(
                :error_location => 'resubmit_to_post_recipients',
                :error_reason => 'post not found',
                :error_code => '404',
                :friendly_error => 'Oops, something went wrong.  Please try again later.'
            )
          end
        else
          render_error_response(
              :error_location => 'resubmit_to_post_recipients',
              :error_reason => 'user not found',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'resubmit_to_post_recipients',
            :error_reason => 'mobile session not found',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'resubmit_to_post_recipients',
          :error_reason => 'missing required_paramater - post_id',
          :error_code => '403',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def get_user_api_accounts
    if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'id,user_id')
      if user = User.first(:conditions => ['id = ?', mobile_session.user_id], :select => ['id'])
        api_accounts = ApiAccount.all(:conditions => ['user_id = ? AND status != ?', user.id, STATUS_DELETED], :select => 'id,api_source,real_name,image_url,reauth_required,user_id')

        if slinggit_twitter_posting_on?
          slinggit_twitter_api_account = ApiAccount.first(:conditions => ['user_id = ? AND user_name = ?', 0, Rails.configuration.slinggit_username], :select => 'id,api_source,real_name,image_url,reauth_required,user_id')
          if not slinggit_twitter_api_account.blank?
            api_accounts << slinggit_twitter_api_account
          end
        end

        api_accounts_array = []
        api_accounts.each do |api_account|
          api_accounts_array << {
              :id => api_account.id.to_s,
              :api_source => api_account.api_source,
              :real_name => api_account.real_name,
              :image_url => api_account.image_url,
              :reauth_required => api_account.reauth_required,
              :user_id => api_account.user_id
          }
        end

        return_data = {
            :rows_found => api_accounts.length.to_s,
            :api_accounts => api_accounts_array
        }

        render_success_response(return_data)

      else
        render_error_response(
            :error_location => 'get_user_api_accounts',
            :error_reason => 'user not found',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'get_user_api_accounts',
          :error_reason => 'mobile session not found',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def password_reset
    @email_or_username = params[:email_or_username]
    if not @email_or_username.blank?
      if user = User.first(:conditions => ['email = ? or name = ?', @email_or_username.downcase, @email_or_username.downcase], :select => 'id,email,password_reset_code,name,slug')
        if user.password_reset_code.blank?
          user.update_attribute(:password_reset_code, Digest::SHA1.hexdigest("#{rand(999999)}-#{Time.now}-#{@email}"))
        end
        UserMailer.password_reset(user).deliver
        render_success_response(
            :email_sent_to => user.email,
            :password_reset_code => user.password_reset_code
        )
      else
        render_error_response(
            :error_location => 'password_reset',
            :error_reason => 'not found - user',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'password_reset',
          :error_reason => 'missing required_paramater - email_or_username',
          :error_code => '403',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def get_post_comments
    if not params[:post_id].blank?
      if not params[:limit].blank?
        if post = Post.first(:conditions => ['id = ? and status = ?', params[:post_id], STATUS_ACTIVE], :select => 'id')
          #limit cannot be 0
          limit = params[:limit].to_i
          limit = 1 if limit <= 0

          #starting_comment_id can come in as 0 or blank and needs to be set to the max + 1 if thats the case
          #we always need to inc by 1
          starting_comment_id = params[:starting_comment_id]

          if (starting_comment_id.blank? or starting_comment_id.to_i <= 0)
            starting_comment_id = Comment.find_by_sql('select id from comments order by id desc limit 1')
            if not starting_comment_id.blank?
              starting_comment_id = starting_comment_id.first.id + 1
            end
          end

          starting_comment_id = 0 if starting_comment_id.blank?
          starting_comment_id = starting_comment_id.to_i

          comments = Comment.all(:conditions => ['post_id = ? AND status != ? AND id < ?', post.id, STATUS_DELETED, starting_comment_id], :order => 'created_at desc, status desc', :limit => limit, :select => 'id,body,user_id,created_at')
          render_success_response(
              :rows_found => comments.length,
              :filters_used => {:limit => limit, :starting_comment_id => starting_comment_id},
              :comments => comments.map { |m|
                m.attributes.merge(
                    :created_at_time => m.created_at.strftime("%H:%M"),
                    :created_at_date => m.created_at.strftime("%m-%d-%Y"),
                    :user_name => m.user.name
                )
              }
          )
        else
          render_error_response(
              :error_location => 'get_post_comments',
              :error_reason => 'not found - post',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'get_post_comments',
            :error_reason => 'missing required_paramater - limit',
            :error_code => '403',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'get_post_comments',
          :error_reason => 'missing required_paramater - post_id',
          :error_code => '403',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def create_post_comment
    if not params[:post_id].blank?
      if not params[:comment_body].blank?
        if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'id,user_id')
          if post = Post.first(:conditions => ['id = ? and status = ?', params[:post_id], STATUS_ACTIVE], :select => 'id')
            comment = Comment.create(
                :post_id => params[:post_id],
                :user_id => mobile_session.user_id,
                :body => params[:comment_body]
            )

            if user = User.first(:conditions => ['id = ?', mobile_session.user_id], :select => 'id')
              add_to_watchedposts(user, post.id)
            end

            render_success_response(
                :comment_id => comment.id
            )
          else
            render_error_response(
                :error_location => 'create_post_comment',
                :error_reason => 'not found - post',
                :error_code => '404',
                :friendly_error => 'Oops, something went wrong.  Please try again later.'
            )
          end
        else
          render_error_response(
              :error_location => 'create_post_comment',
              :error_reason => 'not found - mobile_session',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'create_post_comment',
            :error_reason => 'missing required_paramater - comment_body',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'create_post_comment',
          :error_reason => 'missing required_paramater - post_id',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def delete_post_comment
    if not params[:post_id].blank?
      if not params[:comment_id].blank?
        if Post.exists?(['id = ?', params[:post_id]])
          if comment = Comment.first(:conditions => ['post_id = ? and id = ?', params[:post_id], params[:comment_id]])
            comment.update_attribute(:status, STATUS_DELETED)
            render_success_response(
                :comment_id => comment.id,
                :status => comment.status
            )
          else
            render_error_response(
                :error_location => 'delete_post_comment',
                :error_reason => 'not found - comment for owner',
                :error_code => '404',
                :friendly_error => 'Oops, something went wrong.  Please try again later.'
            )
          end
        else
          render_error_response(
              :error_location => 'delete_post_comment',
              :error_reason => 'not found - post',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'delete_post_comment',
            :error_reason => 'missing required_paramater - comment_id',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'delete_post_comment',
          :error_reason => 'missing required_paramater - post_id',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def get_messages
    if not params[:offset].blank?
      if not params[:limit].blank?
        if mobile_session = MobileSession.first(:conditions => ['mobile_auth_token = ?', @mobile_auth_token], :select => 'user_id')
          if user = User.first(:conditions => ['id = ?', mobile_session.user_id], :select => ['id'])
            #offset can be 0
            offset = params[:offset].to_i
            offset = 0 if offset < 0

            #limit cannot be 0
            limit = params[:limit].to_i
            limit = 1 if limit <= 0

            #starting_message_id can come in as 0 or blank and needs to be set to the max + 1 if thats the case
            #we always need to inc by 1
            starting_message_id = params[:starting_message_id]

            if (starting_message_id.blank? or starting_message_id.to_i <= 0)
              starting_message_id = Message.find_by_sql('select id from messages order by id desc limit 1')
              if not starting_message_id.blank?
                starting_message_id = starting_message_id.first.id + 1
              end
            end

            starting_message_id = 0 if starting_message_id.blank?
            starting_message_id = starting_message_id.to_i

            messages = Message.all(:conditions => ['recipient_user_id = ? AND recipient_status != ? AND id < ?', user.id, STATUS_DELETED, starting_message_id], :order => 'created_at desc, status desc', :limit => limit, :offset => offset, :select => 'id,sender_user_id,recipient_user_id,source,source_id,contact_info_json,body,status,sender_status,recipient_status,created_at')
            number_unread = Message.count(:conditions => ['recipient_user_id = ? AND recipient_status = ?', user.id, STATUS_UNREAD])
            render_success_response(
                :number_unread => number_unread,
                :rows_found => messages.length,
                :filters_used => {:offset => offset, :limit => limit, :starting_message_id => starting_message_id},
                :messages => messages.map { |m|
                  m.contact_info_json = (ActiveSupport::JSON.decode(m.contact_info_json)).merge(:user_name => m.sender_user_name)
                  source_object = m.source_object(:table => 'Post', :columns => 'status,hashtag_prefix,content')
                  source_object_attributes = nil
                  source_object_attributes = source_object.attributes if not source_object.blank?
                  m.attributes.merge(
                      :created_at_time => m.created_at.strftime("%H:%M"),
                      :created_at_date => m.created_at.strftime("%m-%d-%Y"),
                      :source_object_data => source_object_attributes
                  )
                }
            )
          else
            render_error_response(
                :error_location => 'get_messages',
                :error_reason => 'user not found',
                :error_code => '404',
                :friendly_error => 'Oops, something went wrong.  Please try again later.'
            )
          end
        else
          render_error_response(
              :error_location => 'get_messages',
              :error_reason => 'mobile session not found',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'get_messages',
            :error_reason => 'missing required_paramater - limit',
            :error_code => '403',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'get_messages',
          :error_reason => 'missing required_paramater - offset',
          :error_code => '403',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def get_watchedposts
    if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'id,user_id')
      if user = User.first(:conditions => ['id = ?', mobile_session.user_id], :select => ['id'])
        watchedposts = Watchedpost.all(:conditions => ['user_id = ?', user.id], :select => 'post_id')

        return_data = []
        watchedposts.each do |watched_post|
          post = Post.first(:conditions => ['id = ?', watched_post.post_id])
          return_data << post.attributes.merge!(
              :created_at_time => post.created_at.strftime("%H:%M"),
              :created_at_date => post.created_at.strftime("%m-%d-%Y"),
              :image_uri => post.has_photo? ? "#{BASEURL}/#{post.photo.url(:search)}" : nil,
          )
        end
        render_success_response(
            :rows_found => watchedposts.length,
            :posts => return_data
        )
      else
        render_error_response(
            :error_location => 'get_watchedposts',
            :error_reason => 'user not found',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'get_watchedposts',
          :error_reason => 'mobile session not found',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end


  def delete_post
    if not params[:post_id].blank?
      if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'id,user_id')
        if post = Post.first(:conditions => ['id = ? and user_id = ?', params[:post_id], mobile_session.user_id], :select => 'id,status')
          post.update_attribute(:status, STATUS_DELETED)
          Watchedpost.destroy_all(['post_id = ?', post.id])
          render_success_response(
              :post_id => post.id,
              :status => post.status
          )
        else
          render_error_response(
              :error_location => 'delete_post',
              :error_reason => 'not found - post',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'delete_post',
            :error_reason => 'not found - mobile_session',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'delete_post',
          :error_reason => 'missing required_paramater - post_id',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def close_post
    if not params[:post_id].blank?
      if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'id,user_id')
        if post = Post.first(:conditions => ['id = ? and user_id = ?', params[:post_id], mobile_session.user_id], :select => 'id,status')
          post.update_attribute(:status, STATUS_CLOSED)
          render_success_response(
              :post_id => post.id,
              :status => post.status
          )
        else
          render_error_response(
              :error_location => 'close_post',
              :error_reason => 'not found - post',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'close_post',
            :error_reason => 'not found - mobile_session',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'close_post',
          :error_reason => 'missing required_paramater - post_id',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def get_post_image
    if not params[:image_style].blank?

      #check to see if app is requesting the placeholder image and return it
      #the app could technically just grab the image with its name, however, if we move it or decide to change the name, this will allow more flexibility
      if PLACEHOLDER_IMAGE_STYLES.include? params[:image_style]
        if File.exists? "#{Rails.root}/app/assets/images/#{params[:image_style]}.png"
          render_success_response(
              :place_holder => true,
              :image_uri => "#{BASEURL}/assets/#{params[:image_style]}.png"
          ) and return
        else
          render_error_response(
              :error_location => 'get_post_image',
              :error_reason => 'place holder image file does not exist on the server',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          ) and return
        end
      end

      if not params[:post_id].blank?
        if post = Post.first(:conditions => ['id = ?', params[:post_id]], :select => 'id,photo_file_name,photo_content_type,photo_file_size,photo_updated_at,status')
          if not post.status == STATUS_DELETED
            if post.has_photo?
              render_success_response(
                  :post_id => post.id,
                  :place_holder => false,
                  :image_uri => "#{BASEURL}/#{post.photo.url(params[:image_style].to_sym)}"
              )
            else
              render_error_response(
                  :error_location => 'get_post_image',
                  :error_reason => 'post does not contain a photo',
                  :error_code => '404',
                  :friendly_error => 'Oops, something went wrong.  Please try again later.'
              )
            end
          else
            render_error_response(
                :error_location => 'get_post_image',
                :error_reason => 'post has been deleted',
                :error_code => '404',
                :friendly_error => 'Oops, something went wrong.  Please try again later.'
            )
          end
        else
          render_error_response(
              :error_location => 'get_post_image',
              :error_reason => 'not found - post',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end


      else
        render_error_response(
            :error_location => 'get_post_image',
            :error_reason => 'missing required_paramater - post_id',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'get_post_image',
          :error_reason => 'missing required_paramater - image_style',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def send_message
    if not params[:recipient_user_id].blank?
      if not params[:body].blank?
        if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'id,user_id')
          if recipient = User.first(:conditions => ['id = ? AND status != ?', params[:recipient_user_id].to_i, STATUS_DELETED], :select => 'email')
            message = Message.new(
                :send_email => true,
                :sender_user_id => mobile_session.user_id,
                :recipient_user_id => params[:recipient_user_id].to_i,
                :contact_info_json => recipient.email,
                :body => params[:body],
                :recipient_status => STATUS_UNREAD,
                :sender_status => STATUS_UNREAD
            )

            if not params[:post_id].blank?
              if post = Post.first(:conditions => ['id = ?', params[:post_id]], :select => 'id,user_id')
                thread_id = Digest::SHA1.hexdigest(SLINGGIT_SECRET_HASH + post.id.to_s + post.user_id.to_s) + "_#{mobile_session.user_id.to_s}"
                message.source = 'post'
                message.source_id = params[:post_id].to_i
                message.thread_id = thread_id
              end
            end

            if message.save

              if not params[:post_id].blank? and user = User.first(:conditions => ['id = ?', mobile_session.user_id], :select => 'id')
                add_to_watchedposts(user, params[:post_id])
              end

              render_success_response(
                  :message_id => message.id,
                  :email_sent => true
              )
            else
              render_error_response(
                  :error_location => 'send_message',
                  :error_reason => message.errors.messages,
                  :error_code => '404',
                  :friendly_error => 'Oops, something went wrong.  Please try again later.'
              )
            end

          else
            render_error_response(
                :error_location => 'send_message',
                :error_reason => 'recipient user object was either not found or has been deleted',
                :error_code => '404',
                :friendly_error => 'Oops, something went wrong.  Please try again later.'
            )
          end
        else
          render_error_response(
              :error_location => 'send_message',
              :error_reason => 'not found - mobile_session',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'send_message',
            :error_reason => 'missing required_paramater - body',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'send_message',
          :error_reason => 'missing required_paramater - recipient_user_id',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def reply_to_message
    if not params[:parent_message_id].blank?
      if not params[:body].blank?
        if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'id,user_id')
          if parent_message = Message.first(:conditions => ['id = ? and recipient_user_id = ?', params[:parent_message_id], mobile_session.user_id])
            message = Message.new(
                :sender_user_id => mobile_session.user_id,
                :recipient_user_id => parent_message.sender_user_id,
                :source => parent_message.source,
                :source_id => parent_message.source_id,
                :body => params[:body],
                :contact_info_json => ActiveSupport::JSON.decode(parent_message.contact_info_json)['email'],
                :parent_id => parent_message.id,
                :recipient_status => STATUS_UNREAD,
                :sender_status => STATUS_UNREAD,
                :thread_id => parent_message.thread_id,
                :send_email => true
            )

            if message.save
              render_success_response(
                  :message_id => message.id,
                  :email_sent => true
              )
            else
              render_error_response(
                  :error_location => 'reply_to_message',
                  :error_reason => message.errors.messages,
                  :error_code => '404',
                  :friendly_error => 'Oops, something went wrong.  Please try again later.'
              )
            end
          else
            render_error_response(
                :error_location => 'reply_to_message',
                :error_reason => 'not found - parent_message',
                :error_code => '404',
                :friendly_error => 'Oops, something went wrong.  Please try again later.'
            )
          end
        else
          render_error_response(
              :error_location => 'reply_to_message',
              :error_reason => 'not found - mobile_session',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'reply_to_message',
            :error_reason => 'missing required_paramater - body',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'reply_to_message',
          :error_reason => 'missing required_paramater - parent_message_id',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def delete_message
    if not params[:message_ids].blank?
      if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'id,user_id')

        messages_deleted = 0
        messages_not_deleted = 0

        #grabbing all messages before verifying owner such that if for some reason its a mixed bag I can report back to the app that some were deleted and others werent so we can fix the problem.
        messages = Message.all(:conditions => ['id in (?)', params[:message_ids].split(',')], :select => 'id,recipient_user_id,status')
        messages.each do |message|
          if message.recipient_user_id == mobile_session.user_id
            message.update_attribute(:recipient_status, STATUS_DELETED)
            messages_deleted += 1
          else
            messages_not_deleted += 1
          end
        end

        render_success_response(
            :message_ids => params[:message_ids],
            :logged_in_user_id => mobile_session.user_id,
            :rows_found => messages.length,
            :messages_deleted => messages_deleted,
            :messages_not_deleted => messages_not_deleted,
            :note => 'Messages not deleted should never be greater than 0.  If it is greater than 0, that means message ids are being passed in that dont belong to the logged in user'
        )
      else
        render_error_response(
            :error_location => 'delete_message',
            :error_reason => 'not found - mobile_session',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'delete_message',
          :error_reason => 'missing required_paramater - message_ids',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def mark_message_read
    if not params[:message_ids].blank?
      if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'id,user_id')

        messages_marked_read = 0
        messages_not_marked_read = 0

        #grabbing all messages before verifying owner such that if for some reason its a mixed bag I can report back to the app that some were deleted and others werent so we can fix the problem.
        messages = Message.all(:conditions => ['id in (?)', params[:message_ids].split(',')], :select => 'id,recipient_user_id,status')
        messages.each do |message|
          if message.recipient_user_id == mobile_session.user_id
            message.update_attribute(:recipient_status, STATUS_READ)
            messages_marked_read += 1
          else
            messages_not_marked_read += 1
          end
        end

        render_success_response(
            :message_ids => params[:message_ids],
            :logged_in_user_id => mobile_session.user_id,
            :rows_found => messages.length,
            :messages_marked_read => messages_marked_read,
            :messages_not_marked_read => messages_not_marked_read,
            :note => 'Messages not marked read should never be greater than 0.  If it is greater than 0, that means message ids are being passed in that dont belong to the logged in user'
        )
      else
        render_error_response(
            :error_location => 'mark_message_read',
            :error_reason => 'not found - mobile_session',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'mark_message_read',
          :error_reason => 'missing required_paramater - message_ids',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

#TODO SEND EMAIL TO INFORM OF PASSWORD CHANGE
  def change_password
    if not params[:old_password].blank?
      if not params[:new_password].blank?
        if params[:new_password].length >= 6
          if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'id,user_id')
            if user = User.first(:conditions => ['id = ?', mobile_session.user_id])
              if user.authenticate(params[:old_password])
                user.password = params[:new_password]
                user.password_confirmation = params[:new_password]
                if user.save
                  render_success_response(
                      :password_changed => true,
                      :logged_in_user_id => mobile_session.user_id
                  )
                else
                  render_error_response(
                      :error_location => 'change_password',
                      :error_reason => user.errors.messages,
                      :error_code => '404',
                      :friendly_error => 'Oops, something went wrong.  Please try again later.'
                  )
                end
              else
                render_error_response(
                    :error_location => 'change_password',
                    :error_reason => 'authentication with old password failed',
                    :error_code => '401',
                    :friendly_error => 'Current password is incorrect'
                )
              end
            else
              render_error_response(
                  :error_location => 'change_password',
                  :error_reason => 'not found - user',
                  :error_code => '404',
                  :friendly_error => 'Oops, something went wrong.  Please try again later.'
              )
            end
          else
            render_error_response(
                :error_location => 'change_password',
                :error_reason => 'not found - mobile_session',
                :error_code => '404',
                :friendly_error => 'Oops, something went wrong.  Please try again later.'
            )
          end
        else
          render_error_response(
              :error_location => 'change_password',
              :error_reason => 'password is too short',
              :error_code => '401',
              :friendly_error => 'New password needs to be at least 6 characters.'
          )
        end
      else
        render_error_response(
            :error_location => 'change_password',
            :error_reason => 'missing required_paramater - new_password',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'change_password',
          :error_reason => 'missing required_paramater - old_password',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

#TODO SEND EMAIL TO VERIFY NEW EMAIL
  def change_email
    if not params[:new_email].blank?
      if params[:new_email] =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
        if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'id,user_id')
          if user = User.first(:conditions => ['id = ?', mobile_session.user_id], :select => 'id,email,name')
            user.email = params[:new_email]
            user.status = STATUS_UNVERIFIED
            if user.save
              render_success_response(
                  :email_changed => true,
                  :new_email => params[:new_email],
                  :user_status => STATUS_UNVERIFIED,
                  :logged_in_user_id => mobile_session.user_id
              )
            else
              render_error_response(
                  :error_location => 'change_email',
                  :error_reason => user.errors.messages,
                  :error_code => '404',
                  :friendly_error => 'Oops, something went wrong.  Please try again later.'
              )
            end
          else
            render_error_response(
                :error_location => 'change_email',
                :error_reason => 'not found - user',
                :error_code => '404',
                :friendly_error => 'Oops, something went wrong.  Please try again later.'
            )
          end
        else
          render_error_response(
              :error_location => 'change_email',
              :error_reason => 'not found - mobile_session',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'change_email',
            :error_reason => 'new email address is not a valid format',
            :error_code => '404',
            :friendly_error => 'The email address entered is not valid.'
        )
      end
    else
      render_error_response(
          :error_location => 'change_email',
          :error_reason => 'missing required_paramater - new_email',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def get_active_sessions
    if current_mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'id,user_id')
      mobile_sessions = MobileSession.all(:conditions => ['user_id = ? AND id != ?', current_mobile_session.user_id, current_mobile_session.id], :select => 'id,user_id,unique_identifier,device,_name,id_address,created_at', :order => 'created_at desc')
      if mobile_sessions.length > 0
        render_success_response(
            :rows_found => mobile_sessions.length,
            :logged_in_user_id => current_mobile_session.user_id,
            :mobile_sessions => mobile_sessions.map { |ms|
              ms.attributes.merge(
                  :created_at_time => ms.created_at.strftime("%H:%M"),
                  :created_at_date => ms.created_at.strftime("%m-%d-%Y")
              )
            }
        )
      else
        render_success_response(
            :rows_found => mobile_sessions.length,
            :logged_in_user_id => current_mobile_session.user_id,
            :mobile_sessions => nil
        )
      end
    else
      render_error_response(
          :error_location => 'get_active_sessions',
          :error_reason => 'not found - mobile_session',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def delete_active_session
    if not params[:session_id].blank?
      if current_mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'id,user_id')
        if session_to_delete = MobileSession.first(:conditions => ['id = ? AND user_id = ?', params[:session_id], current_mobile_session.user_id], :select => 'id')
          if session_to_delete.destroy
            render_success_response(
                :logged_in_user_id => current_mobile_session.user_id,
                :session_deleted => true
            )
          else
            render_error_response(
                :error_location => 'delete_active_session',
                :error_reason => 'unablet to delete session',
                :error_code => '401',
                :friendly_error => 'Oops, something went wrong.  Please try again later.'
            )
          end
        else
          render_error_response(
              :error_location => 'delete_active_session',
              :error_reason => 'not found - session_to_delete',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'delete_active_session',
            :error_reason => 'not found - mobile_session',
            :error_code => '404',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    else
      render_error_response(
          :error_location => 'delete_active_session',
          :error_reason => 'not found - session_id',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  def report_abuse
    if not params[:source].blank?
      if not params[:source_id].blank?
        if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', @state, @mobile_auth_token], :select => 'id,user_id')
          if user = User.first(:conditions => ['id = ?', mobile_session.user_id], :select => 'id,email,name')
            flagged_content = FlaggedContent.create(
                :creator_user_id => user.id,
                :source => params[:content_source],
                :source_id => params[:content_id]
            )

            render_success_response(
                flagged_content.attributes
            )
          else
            render_error_response(
                :error_location => 'report_abuse',
                :error_reason => 'not found - user',
                :error_code => '404',
                :friendly_error => 'Oops, something went wrong.  Please try again later.'
            )
          end
        else
          render_error_response(
              :error_location => 'report_abuse',
              :error_reason => 'not found - mobile_session',
              :error_code => '404',
              :friendly_error => 'Oops, something went wrong.  Please try again later.'
          )
        end
      else
        render_error_response(
            :error_location => 'report_abuse',
            :error_reason => 'missing required_paramater - source_id',
            :error_code => '404',
            :friendly_error => 'The email address entered is not valid.'
        )
      end
    else
      render_error_response(
          :error_location => 'report_abuse',
          :error_reason => 'missing required_paramater - source',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

  #def send_push_notifications
  #  apns_url = Rails.env == 'development' ? PushNotification::APNS_SANDBOX_HOST : PushNotification::APNS_PRODUCTION_HOST
  #  notifications = PushNotification.all(:conditions => {:status => 'new'})
  #  if notifications.length > 0
  #    notifications.each do |notification|
  #      devices = PushNotificationDevice.all(:conditions => ['customer_id = ? AND status = ?', notification.customer_id, PushNotificationDevice::STATUS_ACTIVE])
  #      devices.each do |device|
  #        case device.device_type
  #          when PushNotificationDevice::DEVICE_APPLE
  #            socket, ssl = create_apns_socket(apns_url, PushNotification::APNS_PORT) if socket.nil?
  #            raw_apns_data = device.get_apns_payload(notification.message)
  #            begin
  #              ssl.write(raw_apns_data)
  #              ssl.flush
  #            rescue
  #              ssl.close
  #              socket.close
  #              socket, ssl = create_apns_socket(apns_url, PushNotification::APNS_PORT)
  #
  #              ssl.write(raw_apns_data)
  #              ssl.flush
  #            end
  #          when PushNotificationDevice::DEVICE_ANDROID
  #            # TODO: android push notifications
  #        end
  #      end
  #      notification.update_attribute(:status, 'done')
  #    end
  #  end
  #  render :nothing => true
  #end
  #
  #def check_apns_feedback_service
  #  apns_feedback_url = PRODUCTION_ENV ? PushNotification::APNS_PRODUCTION_FEEDBACK_HOST : PushNotification::APNS_SANDBOX_FEEDBACK_HOST
  #  socket, ssl = create_apns_socket(apns_feedback_url, PushNotification::APNS_FEEDBACK_PORT)
  #
  #  apns_feedback = []
  #  while line = ssl.read(38)
  #    apns_feedback << line.unpack('N1n1H64')[2]
  #  end
  #
  #  if not apns_feedback.empty?
  #    PushNotificationDevice.update_all("status = \"#{PushNotificationDevice::STATUS_UNINSTALLED}\"", ['device_id = ?', apns_feedback])
  #  end
  #
  #  render :nothing => true
  #end
  #
  #def create_apns_socket(url, port)
  #  apns_cert = File.read(APNS_CERT[:filepath]) if File.exists?(APNS_CERT[:filepath])
  #  ctx = OpenSSL::SSL::SSLContext.new
  #  ctx.key = OpenSSL::PKey::RSA.new(apns_cert, APNS_CERT[:password])
  #  ctx.cert = OpenSSL::X509::Certificate.new(apns_cert)
  #
  #  socket = TCPSocket.new(url, port)
  #  socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
  #  ssl = OpenSSL::SSL::SSLSocket.new(socket, ctx)
  #  ssl.sync = true
  #  ssl.connect
  #  return socket, ssl
  #end


  private

  def add_to_watchedposts(user, post_id)
    if not Post.exists?(['id = ? and user_id = ?', post_id, user.id])
      watchedpost = user.watchedposts.build(:post_id => post_id) unless user.post_in_watch_list?(post_id)
      watchedpost.save unless watchedpost.blank?
    end
  end

  def get_all_slinggit_post_data(filter_data)
    matches = []
    if not filter_data[:search_term].blank?
      matches = Post.all(:conditions => ["status = ? AND open = ? AND id < ? AND(content like ? OR hashtag_prefix like ? OR location like ?)", STATUS_ACTIVE, true, filter_data[:starting_post_id], "%#{filter_data[:search_term]}%", "%#{filter_data[:search_term]}%", "%#{filter_data[:search_term]}%"], :order => 'created_at desc', :limit => filter_data[:limit].to_i, :offset => filter_data[:offset], :select => 'id,content,hashtag_prefix,price,open,location,recipient_api_account_ids,created_at,photo_file_name,photo_content_type,photo_file_size,photo_updated_at,user_id,status')
    else
      matches = Post.all(:conditions => ["status = ? AND open = ? AND id < ?", STATUS_ACTIVE, true, filter_data[:starting_post_id]], :order => 'created_at desc', :limit => filter_data[:limit], :offset => filter_data[:offset], :select => 'id,content,hashtag_prefix,price,open,location,recipient_api_account_ids,created_at,photo_file_name,photo_content_type,photo_file_size,photo_updated_at,user_id,status')
    end
    return [true, matches]
  end

  def get_slinggit_post_data_for_user(filter_data)
    matches = []
    if user = User.first(:conditions => ['name = ? AND status != ?', filter_data[:user_name], STATUS_DELETED], :select => 'id')
      if not filter_data[:search_term].blank?
        matches = Post.all(:conditions => ["status = ? AND user_id = ? AND open = ? AND id < ? AND (content like ? OR hashtag_prefix like ? OR location like ?)", STATUS_ACTIVE, user.id, true, filter_data[:starting_post_id], "%#{filter_data[:search_term]}%", "%#{filter_data[:search_term]}%", "%#{filter_data[:search_term]}%"], :order => 'created_at desc', :limit => filter_data[:limit].to_i, :offset => filter_data[:offset], :select => 'id,content,hashtag_prefix,price,open,location,recipient_api_account_ids,created_at,photo_file_name,photo_content_type,photo_file_size,photo_updated_at,user_id,status')
      else
        matches = Post.all(:conditions => ["status = ? AND user_id = ? AND open = ? AND id < ?", STATUS_ACTIVE, user.id, true, filter_data[:starting_post_id]], :order => 'created_at desc', :limit => filter_data[:limit], :offset => filter_data[:offset], :select => 'id,content,hashtag_prefix,price,open,location,recipient_api_account_ids,created_at,photo_file_name,photo_content_type,photo_file_size,photo_updated_at,user_id,status')
      end
      return [true, matches]
    else
      error_hash = {
          :error_location => 'get_slinggit_post_data',
          :error_reason => 'user not found',
          :error_code => '404',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'}
      return [false, error_hash]
    end
  end

  def create_or_update_mobile_auth_token(user_id)
    if not @state.blank?
      if mobile_session = MobileSession.first(:conditions => ['user_id = ? AND unique_identifier = ?', user_id, @state])
        mobile_session.update_attribute(:mobile_auth_token, Digest::SHA1.hexdigest("#{Time.now.to_i}-#{user_id}"))
      else
        mobile_session = MobileSession.create(
            :user_id => user_id.to_i,
            :unique_identifier => @state,
            :device_name => @device_name,
            :ip_address => request.blank? ? 'remote_application' : request.remote_ip,
            :mobile_auth_token => Digest::SHA1.hexdigest("#{Time.now.to_i}-#{user_id}"),
            :options => @options
        )
      end
      return mobile_session.mobile_auth_token
    else
      render_error_response(
          :error_location => 'global',
          :error_reason => 'missing required_paramater - state validation error',
          :error_code => '401',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
      return
    end
  end

#-----RENDERS-----#

  def render_success_response(options = {})
    render :text => {
        :status => SUCCESS_STATUS,
        :result => options
    }.to_json, :content_type => 'application/json'
  end

  def render_error_response(options = {})
    render :text => {
        :status => ERROR_STATUS,
        :result => options
    }.to_json, :content_type => 'application/json'
  end

#----BEFORE FILTERS----#
  def halt_if_banned
    if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', params[:state], params[:mobile_auth_token]], :select => 'user_id')
      if user = User.first(:conditions => ['id = ?', mobile_session.user_id], :select => 'status,account_reactivation_code')
        if user.is_banned?
          render_error_response(
              :error_location => 'global',
              :error_reason => 'User account had been banned.',
              :error_code => '401',
              :friendly_error => 'Your account has been banned for violating our terms of service.',
              :user_agent => request.user_agent
          )
          return
        end
      end
    end
  end

  def halt_if_suspended_or_unverified
    if mobile_session = MobileSession.first(:conditions => ['unique_identifier = ? AND mobile_auth_token = ?', params[:state], params[:mobile_auth_token]], :select => 'user_id')
      if user = User.first(:conditions => ['id = ?', mobile_session.user_id], :select => 'status,account_reactivation_code,email_activation_code')
        if user.is_suspended?
          render_error_response(
              :error_location => 'global',
              :error_reason => 'User account had been suspended.',
              :error_code => '401',
              :friendly_error => 'That action cannot be performed while your account is suspended.',
              :user_agent => request.user_agent
          )
          return
        elsif not user.email_is_verified?
          render_error_response(
              :error_location => 'global',
              :error_reason => 'User account had been suspended.',
              :error_code => '401',
              :friendly_error => 'That action cannot be performed until you have verified your email address.',
              :user_agent => request.user_agent
          )
        end
      end
    end
  end

  def validate_request_authenticity
    if not params[:slinggit_access_token] == SLINGGIT_SECRET_HASH
      render_error_response(
          :error_location => 'global',
          :error_reason => 'authentication failed',
          :error_code => '401',
          :friendly_error => 'Oops, something went wrong.  Please try again later.',
          :user_agent => request.user_agent
      )
      return
    end
  end

  def validate_user_agent
    if not request.user_agent.downcase.include?("slinggit")
      render_error_response(
          :error_location => 'global',
          :error_reason => 'authentication failed - invalid user_agent',
          :error_code => '401',
          :friendly_error => 'Oops, something went wrong.  Please try again later.',
          :user_agent => request.user_agent
      )
      return
    end
  end

  def set_mobile_auth_token
    if params[:mobile_auth_token].blank?
      render_error_response(
          :error_location => 'global',
          :error_reason => 'missing required_paramater - mobile_auth_token',
          :error_code => '401',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
      return
    else
      if MobileSession.exists?(:mobile_auth_token => params[:mobile_auth_token])
        @mobile_auth_token = params[:mobile_auth_token]
      else
        render_error_response(
            :error_location => 'global',
            :error_reason => 'invalid - mobile_auth_token',
            :error_code => '401',
            :friendly_error => 'Your session has expired. Please sign in again.'
        )
        return
      end
    end
  end

  def set_state
    if params[:state].blank?
      render_error_response(
          :error_location => 'global',
          :error_reason => 'missing required_paramater - state',
          :error_code => '401',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
      return
    else
      @state = params[:state]
    end
  end

  def set_device_name
    if params[:device_name].blank?
      render_error_response(
          :error_location => 'global',
          :error_reason => 'missing required_paramater - device_name',
          :error_code => '401',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
      return
    else
      @device_name = params[:device_name]
    end
  end

  def set_options
    if params[:options].blank?
      @options = params[:options]
    end
  end

  def require_post
    if not request.post?
      render_error_response(
          :error_location => 'global',
          :error_reason => 'bad request format',
          :error_code => '400',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
      return
    end
  end

  def set_source
    if MOBILE_VIEW_ACTIONS.include? params[:action].to_sym
      session[:source] = NATIVE_APP_WEB_VIEW
    else
      session[:source] = NATIVE_APP
    end
  end

  def get_temp_photo_path(name)
    "#{Rails.root}/public/tmp_images/#{name}.jpg"
  end

  def validate_request_data_is_valid_json
    if not params[:post_data].blank?
      if not params[:post_data].valid_json?
        render_error_response(
            :error_location => 'global',
            :error_reason => 'post_data is not a valid json string',
            :error_code => '400',
            :friendly_error => 'Oops, something went wrong.  Please try again later.'
        )
      end
    end
  end

  def catch_exceptions
    yield
  rescue => exception
    create_problem_report(exception, Rails.env)
    if session[:source] and session[:source] == NATIVE_APP_WEB_VIEW
      redirect_to :action => :finalize_add_twitter_account, :result_status => ERROR_STATUS, :friendly_error => 'Oops, something went wrong.  Please try again later.', :error_reason => exception.to_s
    else
      render_error_response(
          :error_location => 'global',
          :error_reason => "exception caught: #{exception.message} - #{exception.backtrace}",
          :error_code => '500',
          :friendly_error => 'Oops, something went wrong.  Please try again later.'
      )
    end
  end

end
