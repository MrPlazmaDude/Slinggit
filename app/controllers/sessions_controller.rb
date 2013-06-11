class SessionsController < ApplicationController
  before_filter :signed_in_user, :only => [:index]

  def index
    @mobile_sessions = MobileSession.all(:conditions => ['user_id = ? AND mobile_auth_token IS NOT NULL', current_user.id])
  end

  def new
  end

  def create
    #error messages copied from google
    if not params[:email].blank?
      @email = params[:email]
      user = User.first(:conditions => ['email = ?', @email])

      #try to look up the user by username for convienence
      if user.blank?
        user = User.first(:conditions => ['name = ?', @email])
      end

      if not user.blank? and user.authenticate(params[:password])
        sign_in user
        redirect_back_or user
      else
        flash.now[:error] = 'The username or password you entered is incorrect.'
        render 'new'
      end
    else
      flash.now[:error] = 'Enter your email address.'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  def sign_out_of_device
    if not params[:mobile_session_id].blank?
      mobile_session_id = params[:mobile_session_id].split('_').last
      if mobile_session_id == 'all'
        MobileSession.all(:conditions => ['user_id = ?', current_user.id]).each do |mobile_session|
          mobile_session.update_attribute(:mobile_auth_token, nil)
        end
        render :text => "You have signed out of all mobile devices.", :status => 200
      else
        if mobile_session = MobileSession.first(:conditions => ['user_id = ? AND id = ?', current_user.id, mobile_session_id])
          mobile_session.update_attribute(:mobile_auth_token, nil)
          render :text => "#{mobile_session.device_name} is no longer signed in.", :status => 200
        else
          render :text => 'not found', :status => 500
        end
      end
    end
  end

end
