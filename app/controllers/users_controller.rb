class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:edit, :update, :destroy, :delete_account, :edit_user_email_for_verification, :update_email_and_send_verification, :email_preferences]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :user_verified, only: [:edit, :update, :destroy]

  # Method is in application_controller
  before_filter :set_cache_buster, only: [:edit_user_email_for_verification]

  # Controller specific, non-environement dependent, constants
  USERS_PATH = "/users"

  # CMK: Don't remember if I put this here or not, but will look at once we
  # start our async stuff
  #respond_to :json

  def index
    if signed_in?
      redirect_to current_user
    else
      redirect_to new_user_path
    end
  end

  def request_invitation

    #check to see if the user already exists in the users table as well

    if request.post?
      if not params[:email].blank?
        if invitation = Invitation.first(:conditions => ['email = ?', params[:email]], :select => 'status')
          if invitation.status == 'approved'
            flash.now[:notice] = "Your invitation has already been approved.  Please follow the link in your approval email."
          elsif invitation.status == 'active'
            flash.now[:notice] = "Your invitation has already been activated.  Please log in with your email and password"
          else
            flash.now[:notice] = "You have already requested an invitation.  We will let you know when it has been approved."
          end
        else
          #this will automatically generate an email for us and the user.
          Invitation.create(
              :email => params[:email],
              :comment => params[:comment]
          )
          flash.now[:success] = "Invitation request has been sent.  We will approve it as soon as possible."
          #redirect_to :controller => :static_pages, :action => :home
        end
      else
        flash.now[:error] = "Please give us your email address so we can contact you when your invitation is approved."
      end
    end
  end


  def show
    @label = "My"
    #@passes_limitation = nil
    @user = User.first(:conditions => ['name = ?', params[:id]])
    if signed_in?
      if current_user.id == @user.id
        @passes_limitation = passes_limitations?(:total_posts)
      end
    end
    if not @user.blank? and not @user.is_considered_deleted?
      #@posts = Post.all(:conditions => ['user_id = ? AND status = ? AND open = ?', @user.id, STATUS_ACTIVE, true])
      @posts = Post.paginate(page: params[:page], :per_page => 20, :conditions => ['user_id = ? AND status = ? AND open = ?', @user.id, STATUS_ACTIVE, true])
      #get_posts_for_user 'show', params[:page], 20, @user.id, STATUS_ACTIVE, true
    else
      if signed_in?
        redirect_to current_user
      else
        redirect_to new_user_path
      end
    end
  end

  def watched
  end

  def watching
    @label = "Watched"
    @passes_limitation = passes_limitations?(:total_posts)
    if signed_in? and params[:id] == current_user.name and not current_user.is_considered_deleted?
      @user = current_user
      @posts = []
      Watchedpost.find_each(:conditions => ['user_id = ?', @user.id], :select => 'post_id') do |watched_post|
        @posts << Post.first(:conditions => ['id = ?', watched_post.post_id])
      end
      @posts = @posts.paginate(:page => params[:page], :per_page => 20)
      render 'show'
    else
      redirect_to signin_path
    end
  end

  def archived
    @label = "Archived"
    @passes_limitation = passes_limitations?(:total_posts)
    if signed_in? and params[:id] == current_user.name and not current_user.is_considered_deleted?
      @user = current_user
      @posts = Post.paginate(page: params[:page], :per_page => 20, :conditions => ['user_id = ? AND status = ? AND open = ?', @user.id, STATUS_ACTIVE, false])
      render 'show'
    else
      redirect_to signin_path
    end
  end

  def new
    if invite_only? and params[:id].blank? and session[:approved_invitation].blank?
      flash[:notice] = "We are not currently accepting new users without an invitation."
      redirect_to :action => :request_invitation and return
    elsif invite_only? and not params[:id].blank?
      if invitation = Invitation.first(:conditions => ['activation_code = ?', params[:id]])
        session[:approved_invitation] = invitation
      else
        flash[:notice] = "We are sorry, but the invitation code provided is invalid."
        redirect_to :action => :request_invitation and return
      end
    end

    if session[:user].blank?
      @user = User.new
      if not session[:approved_invitation].blank?
        @user.email = session[:approved_invitation].email
      end
      # CMK: storing return_url here, prior to session reset, so that we can return
      # the use back to, say, a post if it's not nil.
      return_url = session[:return_to]
      approved_invitation = session[:approved_invitation]

      reset_session

      if return_url
        session[:return_to] = return_url
      end

      if approved_invitation
        session[:approved_invitation] = approved_invitation
      end
    else
      @user = session[:user]
      session.delete(:user)
    end
  end

  def create
    if not invite_only? or (invite_only? and not session[:approved_invitation].blank?)
      @user = User.new(params[:user])
      if not invite_only? or (invite_only? and @user.email == session[:approved_invitation].email)
        if not params[:twitter_authenticate].blank?
          success = validate_pre_twitter_data
          if success
            # CMK: so I added :return_url to parameters, so that we can have that after
            # twitter authentication, in order to redirect the use back to, say, a post.
            setup_twitter_call(url_for(:controller => :users, :action => :twitter_signup_callback, :name => @user.name, :email => @user.email, :return_url => session[:return_to]))
          else
            render 'new'
          end
        else
          if @user.save
            if not session['access_token'].blank? and not session['access_secret'].blank?
              client = Twitter::Client.new(oauth_token: session['access_token'], oauth_token_secret: session['access_secret'])
              create_api_account(:source => :twitter, :user_object => @user, :api_object => client)
              session.delete('access_token')
              session.delete('access_secret')
            end
            @user.update_attribute(:email_activation_code, Digest::SHA1.hexdigest(@user.email + "slinggit_email_activation_code" + SLINGGIT_SECRET_HASH))
            UserMailer.welcome_email(@user).deliver
            sign_in @user
            session.delete(:approved_invitation)
            flash[:success] = "Welcome SlingGit.  Please be sure to verify your email address."
            redirect_back_or @user
          else
            render 'new'
          end
        end
      else
        flash[:error] = "The email address you provided did not match the invitation request.  Please be sure to use the same email address you used when you requested an invite."
        redirect_to :action => :new
      end
    else
      flash[:notice] = "We are not currently accepting new users without an invitation."
      redirect_to :action => :request_invitation and return
    end
  end

  def edit_user_email_for_verification
    if current_user.status != STATUS_UNVERIFIED
      flash[:notice] = "You have already verfied your email with us."
      redirect_to user_path(current_user)
    end
  end

  def update_email_and_send_verification
    user_updates = params[:user]
    if current_user.update_attributes(user_updates)
      current_user.update_attribute(:email_activation_code, Digest::SHA1.hexdigest(current_user.email + "slinggit_email_activation_code" + SLINGGIT_SECRET_HASH))
      UserMailer.welcome_email(current_user).deliver
      flash[:success] = "A verification email has been sent to #{current_user.email}"
      redirect_to user_path(current_user)
    else
      render 'edit_user_email_for_verification'
    end
  end

  def edit
  end

  def update
    # @user = User.find(params[:id])  !Not needed because of :correct_user before_filter

    # we dont want to force the user to pass in all attributes, but rather, just the ones they want to change
    user_updates = params[:user]
    user_updates.delete_if { |key, value| value.blank? }

    if @user.update_attributes(user_updates)
      flash[:success] = "Profile updated"
      sign_in @user
      reset_session
      redirect_to @user
    else
      render 'edit'
    end
  end

  def email_preferences
    @email_preference = EmailPreference.first(:conditions => ['user_id = ?', current_user.id])
    if not @email_preference.blank?
      if request.post?
        if not params[:system_emails].blank? and params[:system_emails] == '1'
          @email_preference.system_emails = true
        else
          @email_preference.system_emails = false
        end
        if not params[:marketing_emails].blank? and params[:marketing_emails] == '1'
          @email_preference.marketing_emails = true
        else
          @email_preference.marketing_emails = false
        end
        @email_preference.save
        flash[:success] = "Email preferences updates"
      end
    else
      flash[:error] = "Oops, something has gone wrong.  Please try again later."
      redirect_to @user
    end
  end

  def verify_email
    if not params[:id].blank?
      if user = User.first(:conditions => ['email_activation_code = ?', params[:id]])
        if user.email_activation_code == Digest::SHA1.hexdigest(user.email + "slinggit_email_activation_code" + SLINGGIT_SECRET_HASH)
          user.update_attribute(:email_activation_code, nil)
          user.update_attribute(:status, STATUS_ACTIVE)
          flash[:success] = "Your email has been verified."
          sign_in user
          redirect_to user
        else
          flash[:error] = "Invalid email activation code."
          redirect_to :controller => :static_pages, :action => :home
        end
      else
        flash[:error] = "Invalid email activation code."
        redirect_to :controller => :static_pages, :action => :home
      end
    else
      redirect_to :controller => :static_pages, :action => :home
    end
  end

  def delete_account

  end

  def destroy
    #even if there are errors and they must resubmit, we want to grab the information they enter immidiately and store it...
    #because people tend to be rushed to do things and the second time around they may not enter anything.
    #Or they may enter something entirely different and we should grab both so we have more information as to what our customers want.

    if not params[:reason].blank?
      UserFeedback.create(
          :user_id => current_user.id,
          :source => 'delete_account',
          :information => params[:reason]
      )
    end

    if not params[:password].blank?
      if current_user.authenticate(params[:password])
        current_user.update_attribute(:status, STATUS_DELETED)
        current_user.posts.each do |post|
          post.update_attribute(:status, STATUS_DELETED)
        end
        current_user.update_attribute(:account_reactivation_code, Digest::SHA1.hexdigest(current_user.email + "slinggit_account_reactivation_code" + SLINGGIT_SECRET_HASH))
        UserMailer.account_deleted(current_user).deliver
        UserMailer.inform_admin_account_deleted(current_user).deliver
        sign_out
        reset_session
        flash[:success] = "Your account has been deleted."
        redirect_to :controller => :static_pages, :action => :home
      else
        flash[:error] = "The password you entered is incorrect."
        redirect_to :controller => :users, :action => :delete_account
      end
    else
      flash[:error] = "You must first enter your password."
      redirect_to :controller => :users, :action => :delete_account
    end
  end

  def reactivate
    if not params[:id].blank?
      if user = User.first(:conditions => ['account_reactivation_code = ?', params[:id]])
        user.update_attribute(:status, STATUS_ACTIVE)
        user.posts.each do |post|
          post.update_attribute(:status, STATUS_ACTIVE)
        end
        user.update_attribute(:account_reactivation_code, nil)
        flash[:success] = "Your account has been reactivated.  You may now sign in."
        redirect_to :controller => :sessions, :action => :new
      end
    else
      flash[:error] = "Oops, that link didn't contain all the information we needed to reactivate your account."
      redirect_to :controller => :static_pages, :action => :home
    end
  end

  def password_reset
    #using password_reset instead of forgot_password becuase I feel like the url forgot_password frustrates people or makes them feel dumb.
    @email_or_username = params[:email_or_username]
    if request.post?
      if not @email_or_username.blank?
        if user = User.first(:conditions => ['email = ? or name = ?', @email_or_username.downcase, @email_or_username.downcase], :select => 'id,email,password_reset_code,name,slug')
          if user.password_reset_code.blank?
            user.update_attribute(:password_reset_code, Digest::SHA1.hexdigest("#{rand(999999)}-#{Time.now}-#{@email}"))
          end
          UserMailer.password_reset(user).deliver
          flash.now[:success] = "Password reset instructions have been sent to '#{user.email}'."
        else
          flash.now[:error] = "That email address or username doesn't have a registered user account. Are you sure you've signed up?"
        end
      else
        flash.now[:error] = "We need either an email address, or a username, so we know who to send instructions to."
      end
    end
  end

  def enter_new_password
    #linked to from the forgot password email... id in this case is the password_reset_code in the users table
    @password_reset_code = params[:id] if not params[:id].blank?

    if not @password_reset_code.blank?
      @user = User.first(:conditions => ['password_reset_code = ?', @password_reset_code])
      if @user.blank?
        flash[:error] = 'That password reset code is invalid.'
        redirect_to :controller => :sessions, :action => :new
      else
        if request.post?
          @user.password = params[:password]
          @user.password_confirmation = params[:password_confirmation]
          @user.password_reset_code = nil
          if @user.save
            sign_in @user
            flash[:success] = "Your password has been reset."
            redirect_to @user
          end
        end
      end
    else
      flash[:error] = "Oops, that link didn't contain all the information we needed to reset your password."
      redirect_to :controller => :sessions, :action => :new
    end
  end

  def twitter_signup_callback
    rtoken = session['rtoken']
    rsecret = session['rsecret']

    if not params[:name].blank? and not params[:email].blank?
      session[:user] = User.new(
          :name => params[:name],
          :email => params[:email]
      )
    end
    if not params[:denied].blank?
      flash[:success] = "You can always add your Twitter account later!  For now, all we need is a Slinggit password to get you started."
      session[:no_thanks] = true
      # CMK: storing return url so that we can return a user to a post if he was to signin there
      session[:return_to] = params[:return_url]
      redirect_to new_user_path
    else
      request_token = OAuth::RequestToken.new(oauth_consumer, rtoken, rsecret)
      access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
      session['access_token'] = access_token.token
      session['access_secret'] = access_token.secret
      session[:twitter_permission_granted] = true
      # CMK: storing return url so that we can return a user to a post if he was to signin there
      session[:return_to] = params[:return_url]
      flash[:success] = "Your Twitter account has been authorized.  One last step, please provide a Slinggit password."
      redirect_to new_user_path
    end
  end

  def set_no_thanks
    session[:no_thanks] = true
    render :text => '', :status => 200
  end

  def reset_page_session
    session.delete(:twitter_permission_granted)
    session.delete(:no_thanks)
    render :text => '', :status => 200
  end

  def verify_email_availability
    if request.post?
      if User.exists?(:email => params[:email])
        render :text => 'unavailable', :status => 200
      else
        render :text => 'available', :status => 200
      end
    end
  end

  def verify_username_availability
    if request.post?
      if User.exists?(:name => params[:name])
        render :text => 'unavailable', :status => 200
      else
        render :text => 'available', :status => 200
      end
    end
  end

  private

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_path) unless not current_user.blank? and current_user.is_admin?
  end

  def validate_pre_twitter_data
    #This validates all possible errors for username and email after the user clicks authenticate with twitter
    #on the sign up page

    if params[:user][:name].blank?
      @user.errors.messages[:name] = ["can't be blank"]
    else
      if not params[:user][:name] =~ /\A[a-z0-9_-]{,20}\z/i
        @user.errors.messages[:name] = ["can only contain letters, numbers, underscores and dashes and cannot be more than 20 characters."]
      else
        if User.exists?(:name => params[:user][:name])
          @user.errors.messages[:name] = ["has already been registered"]
        end
      end
    end

    if params[:user][:email].blank?
      @user.errors.messages[:email] = ["can't be blank"]
    else
      if not params[:user][:email] =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
        @user.errors.messages[:email] = ["is invalid"]
      else
        if User.exists?(:email => params[:user][:email])
          @user.errors.messages[:email] = ["has already been registered"]
        end
      end
    end

    if @user.errors.messages.blank?
      return true
    else
      return false
    end
  end

end
