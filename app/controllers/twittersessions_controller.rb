class TwittersessionsController < ApplicationController

  def new
  end

  def create
    setup_twitter_call
  end

  def callback
    #if they are signed in then its coming from the network controller
    if signed_in?
      if not params[:denied].blank?
        flash[:success] = "In order to add your Twitter account, we need you to accept the permissions presented by Twitter."
        redirect_to :controller => :networks, :action => :index
      else
        request_token = OAuth::RequestToken.new(oauth_consumer, session['rtoken'], session['rsecret'])
        access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
        client = Twitter::Client.new(oauth_token: access_token.token, oauth_token_secret: access_token.secret)
        success, result = create_api_account(:source => :twitter, :user_object => current_user, :api_object => client)
        if success
          flash[:success] = "Your Twitter account has been added.  You may now make posts that tweet to this account."
        else
          flash[:error] = result
        end
        redirect_to :controller => :networks, :action => :index
      end
    else
      if not params[:denied].blank?
        flash[:success] = "You can always add your Twitter account later!"
        redirect_to edit_user_path(current_user)
      else
        request_token = OAuth::RequestToken.new(oauth_consumer, session['rtoken'], session['rsecret'])
        access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
        reset_session
        session['access_token'] = access_token.token
        session['access_secret'] = access_token.secret
        redirect_to new_user_path
      end
    end
  end

  # this is the redirect for reauthorization
  def reauthorize
    api_account_post_status = ApiAccountPostStatus.first(:conditions => ['host_machine = ? AND user_id = ? AND status = "processing"', request.env['HTTP_HOST'], current_user.id])
    if api_account_post_status
      @api_account = ApiAccount.first(:conditions => ['id = ? AND user_id = ?', api_account_post_status.triggering_api_account_id, current_user.id])
      if @api_account.blank?
        if api_account_post_status.triggering_api_account_id.blank? or api_account_post_status.triggering_api_account_id == '0'
          #because the slinggit account comes last, that means the rest posted, display success message
          flash[:success] = "Your items were successfully posted on your twitter accounts."
        else
          flash[:error] = "An unexpected error has occured.  Please contact customer service with error code tw-30-re"
        end
        redirect_to current_user
      end
    else
      flash[:error] = "One or more of your selected twitter accounts failed to receive our post.  Please be sure you have not removed permission for Slinggit to post to your accounts."
      redirect_to current_user
    end
  end

  # form action
  def create_reauthorization
    setup_twitter_call(url_for(controller: :twittersessions, action: :reauthorize_callback, email: current_user.email))
  end

  # reauth callback
  def reauthorize_callback
    request_token = OAuth::RequestToken.new(oauth_consumer, session['rtoken'], session['rsecret'])
    access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
    if not params[:email].blank?
      user = User.find_by_email(params[:email])
      if not user.blank?
        client = Twitter::Client.new(oauth_token: access_token.token, oauth_token_secret: access_token.secret)
        update_api_account(:source => :twitter, :user_object => user, :api_object => client)
      end
    end
    redirect_to current_user
  end

end