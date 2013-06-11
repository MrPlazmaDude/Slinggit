class FacebooksessionsController < ApplicationController
  include Rack::Utils

  def new
  end

  def create
    setup_facebook_call('publish_stream')
  end

  def callback
    if params[:error].blank?
      if not params[:code].blank? and not params[:state].blank?
        if params[:state] == Digest::SHA1.hexdigest(SLINGGIT_SECRET_HASH)
          redirect_uri = facebook_callback_url
          access_token_url = URI.escape("https://graph.facebook.com/oauth/access_token?client_id=#{Rails.configuration.facebook_app_id}&redirect_uri=#{redirect_uri}&client_secret=#{Rails.configuration.facebook_app_secret}&code=#{params[:code]}")
          begin
            client = HTTPClient.new
            access_token_response = client.get_content(access_token_url)

            if not access_token_response.blank?
              if access_token_response.include? 'error'
                decoded_error_response = ActiveSupport::JSON.decode(access_token_response)
                flash[:error] = "Oops, something went wrong.  Please try again later."
                redirect_to :controller => :networks, :action => :index
              else
                access_token_and_expiration = parse_nested_query(access_token_response)
                basic_user_info_response = client.get_content("https://graph.facebook.com/me?access_token=#{access_token_and_expiration['access_token']}")
                if not basic_user_info_response.blank?
                  decoded_basic_user_info = ActiveSupport::JSON.decode(basic_user_info_response)
                  decoded_basic_user_info.merge!(access_token_and_expiration)
                  success, result = create_api_account(:source => :facebook, :user_object => current_user, :api_object => decoded_basic_user_info)
                  if success
                    flash[:success] = "Your Facebook account has been added.  You may now make posts that show up on your wall."
                  else
                    flash[:error] = result
                  end
                  redirect_to :controller => :networks, :action => :index
                end
              end
            else
              flash[:error] = "Oops, something went wrong.  Please try again later."
              redirect_to :controller => :networks, :action => :index
            end
          rescue Exception => exception
            create_problem_report(exception, Rails.env)
            if PROD_ENV
              flash[:error] = "Oops, something went wrong.  We have been notified and will fix the issue rapidly."
              redirect_to :controller => :networks, :action => :index
            else
              raise exception
            end
          end
        else
          flash[:error] = "Uh oh, we couldn't verify the authenticity of your request.  Please try again later'."
          redirect_to :controller => :networks, :action => :index
        end
      else
        flash[:error] = "Oops, something went wrong.  Please try again later."
        redirect_to :controller => :networks, :action => :index
      end
    else
      flash[:error] = "In order to add your Facebook account, we need you to accept the permissions presented by Facebook."
      redirect_to :controller => :networks, :action => :index
    end
  end

  # this is the redirect for reauthorization
  def reauthorize

  end

  # form action
  def create_reauthorization

  end

  # reauth callback
  def reauthorize_callback

  end

end