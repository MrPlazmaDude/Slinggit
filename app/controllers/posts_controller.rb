class PostsController < ApplicationController

  before_filter :user_verified, only: [:create, :destroy, :edit, :new]
  before_filter :signed_in_user, only: [:create, :destroy, :edit, :new]
  before_filter :non_suspended_user, only: [:new]
  before_filter :correct_user, only: [:destroy, :edit, :update]
  before_filter :load_api_accounts, :only => [:new, :create, :edit]
  before_filter :get_id_for_slinggit_api_account, :only => [:new, :create, :edit]

  def index
    @posts = Post.paginate(page: params[:page], :per_page => 10, :conditions => ['open = ? AND status = ?', true, STATUS_ACTIVE], :order => 'id desc')
  end

  def filtered_list
  end

  def show
    if not params[:id].blank?
      @additional_photo = AdditionalPhoto.new

      #this conditional is only until we know we have handled all links that still pass in the standard id
      if params[:id].length == 40
        @post = Post.first(:conditions => ['id_hash = ?', params[:id]])
      else
        @post = Post.first(:conditions => ['id = ?', params[:id]])
      end

      if not @post.blank? and not @post.is_banned?
        @comments = @post.comments.paginate(page: params[:page], :conditions => ['status = ?', STATUS_ACTIVE])
        # creating user object to compare against current_user
        # in order to display edit option.  Dan, if there's a
        # better way, fell free to change this.
        @user = User.find(@post.user_id)

        @twitter_posts = TwitterPost.all(:conditions => ['post_id = ?', @post.id], order: "created_at DESC")
        @facebook_posts = FacebookPost.all(:conditions => ['post_id = ?', @post.id], order: "created_at DESC")

        # Since we give an non-singed in user the option to sign in, we
        # want to return them to the post after signin.
        unless signed_in?
          store_location
        end
      else
        flash[:notice] = 'Oops, the post you are looking for either does not exist or has been removed'
        redirect_to :controller => 'static_pages', :action => 'home'
      end
    else
      flash[:notice] = 'Sorry, but we couldnt find the post you were looking for.  Check out these other posts.'
      redirect_to :controller => 'posts'
    end
  end

  def new
    @post = Post.new
    success, friendly_error_message = passes_limitations?(:total_posts)
    if not success
      @cant_post = true
      flash[:notice] = friendly_error_message
      redirect_to user_path(current_user)
    end
  end

  def create
    recipient_api_account_ids = []
    selected_networks = params[:selected_networks]
    params.delete(:selected_networks)

    @post = current_user.posts.build(params[:post])
    if not @post.save
      render 'new'
      return
    else
      if not selected_networks.blank?
        post_to_social_newtorks(@post, selected_networks)
      end
      flash[:success] = "Post successfully created!"
      redirect_to current_user
    end
  end

  def edit
    # Don't need to find Post here because of correct_user filter
  end

  def update
    # Don't need to find Post here because of correct_user filter
    social_networks = params[:selected_networks]
    params.delete(:selected_networks)

    if @post.update_attributes(params[:post])
      if params[:post] and params[:post][:open] == 'false'
        flash[:success] = "Post Closed"
      else
        repost @post, social_networks unless social_networks.blank?
        flash[:success] = "Successfully Reposted"
      end
      redirect_back_or post_path(@path)
    else
      render 'edit'
    end
  end

  def add_image
    puts 'steve'
  end

  def delete_post
    post = Post.first(:conditions => ['id = ?', params[:id]])
    if not post.blank? and post.user_id == current_user.id
      if post.update_attribute(:status, STATUS_DELETED)
        Watchedpost.destroy_all(['post_id = ?', post.id])
        flash[:success] = "Post #{post.hashtag_prefix} successfully removed."
        redirect_to user_path(current_user)
      end
    end
  end

  def results
    #rework this again later
    search_terms = []
    @posts = []
    if not params[:id].blank?
      @search_terms_entered = params[:id].gsub!('#', '')
      search_terms = params[:id].split(' ')
      if search_terms.length > 1
        @posts = Post.all(:conditions => ["(content in (?) OR hashtag_prefix in (?) OR location in (?)) AND open = ? AND status = ?", search_terms, search_terms, search_terms, true, STATUS_ACTIVE], :order => 'created_at desc')
        if @posts.length == 0
          search_terms = search_terms[0, 3]
          search_terms.each do |search_term|
            search_term = search_term[1, search_terms.length - 1]
            @posts | Post.all(:conditions => ["(content like ? OR hashtag_prefix like ? OR location like ?) AND open = ? AND status = ?", "%#{search_terms}%", "%#{search_terms}%", "%#{search_terms}%", true, STATUS_ACTIVE], :order => 'created_at desc')
          end
        end
      elsif search_terms.length == 1
        @posts = Post.all(:conditions => ["(content like ? OR hashtag_prefix like ? OR location like ?) AND open = ? AND status = ?", "%#{search_terms[0]}%", "%#{search_terms[0]}%", "%#{search_terms[0]}%", true, STATUS_ACTIVE], :order => 'created_at desc')
        if @posts.length == 0
          search_term = search_terms[0][1, search_terms.length - 1]
          @posts = Post.all(:conditions => ["(content like ? OR hashtag_prefix like ? OR location like ?) AND open = ? AND status = ?", search_term, search_term, search_term, true, STATUS_ACTIVE], :order => 'created_at desc')
        end
      end

      if @posts.length == 0
        flash[:notice] = "No posts were found using <strong>#{params[:id]}</strong>.  Here are some recent posts.".html_safe
        redirect_to :controller => :posts, :action => :index
      end
    else
      flash[:notice] = "We didn't have anything to search on. Here are some recent posts."
      redirect_to :controller => :posts, :action => :index
    end
  end

  def report_abuse
    if not params[:id].blank?
      if post = Post.first(:conditions => ['id_hash = ?', params[:id]])
        FlaggedContent.create(
            :creator_user_id => signed_in? ? current_user.id : nil,
            :source => 'post',
            :source_id => post.id
        )
        flash[:success] = "Post has been flagged and will be reviewed as soon as possible."
      end
    end

    if not request.referer.blank?
      redirect_to request.referer
    else
      redirect_to post_path
    end
  end

  def edit_field
    if request.post?
      if not params[:id].blank? and not params[:field].blank? and not params[:value].blank?
        if post = Post.first(:conditions => ['id_hash = ? AND user_id = ?', params[:id], current_user.id])
          location_before_save = post.location
          price_before_save = post.price
          hashtag_prefix_before_save = post.hashtag_prefix
          content_before_save = post.content
          case params[:field]
            when 'price'
              post.price = params[:value]
              if post.save
                render :text => "$#{params[:value]}", :status => 200
              else
                render :text => "$#{price_before_save}", :status => 500
              end
            when 'location'
              post.location = params[:value]
              if post.save
                render :text => "#{params[:value]}", :status => 200
              else
                render :text => "#{location_before_save}", :status => 500
              end
            when 'hashtag_prefix'
              post.hashtag_prefix = params[:value]
              if post.save
                render :text => "#{params[:value]}", :status => 200
              else
                render :text => "#{hashtag_prefix_before_save}", :status => 500
              end
            when 'content'
              post.content = params[:value]
              if post.save
                render :text => "#{params[:value]}", :status => 200
              else
                render :text => "#{content_before_save}", :status => 500
              end
          end
        end
      end
    end
  end


  private

  def repost post, social_networks
    if not post.blank? and not social_networks.blank?
      post_to_social_newtorks(post, social_networks)
    end
  end

  def post_to_social_newtorks post, social_networks
    recipient_api_account_ids = []

    social_networks.each do |id, value|
      # We need to first make sure the user is the owner of this account, or that
      # it is the slinggit account. Should we log a volation here?
      if proposed_api_account = ApiAccount.first(:conditions => ['id = ?', id], :select => 'user_id,api_source')
        if current_user.id == proposed_api_account.user_id || proposed_api_account.user_id == 0
          recipient_api_account_ids << id
          if proposed_api_account.api_source == 'twitter'
            TwitterPost.create(
                :user_id => post.user_id,
                :api_account_id => id.to_i,
                :post_id => post.id,
                :content => post.content
            ).do_post
          elsif proposed_api_account.api_source == 'facebook'
            redirect = Redirect.get_or_create(
                :target_uri => "#{BASEURL}/posts/#{post.id_hash}"
            )
            FacebookPost.create(
                :user_id => post.user_id,
                :api_account_id => id.to_i,
                :post_id => post.id,
                :message => "##{post.hashtag_prefix} for sale at #{redirect.get_short_url}",
                :name => "$#{post.price}.00",
                :caption => "Location: #{post.location}",
                :description => post.content,
                :image_url => post.has_photo? ? "#{BASEURL}#{post.root_url_path}" : "#{Rails.root}/app/assets/images/noPhoto_80x80.png",
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

  def correct_user
    if signed_in?
      @post = Post.first(:conditions => ['user_id = ? AND id = ? AND status = ?', current_user.id, params[:id], STATUS_ACTIVE])
      if @post.blank?
        redirect_to current_user
      end
    else
      redirect_to new_user_path
    end
  end

  def load_api_accounts
    @twitter_accounts = ApiAccount.all(:conditions => ['user_id = ? AND api_source = ? AND status != ?', current_user.id, 'twitter', STATUS_DELETED])
    @facebook_accounts = ApiAccount.all(:conditions => ['user_id = ? AND api_source = ? AND status != ?', current_user.id, 'facebook', STATUS_DELETED])
  end

  def get_id_for_slinggit_api_account
    slinggit_api_account = ApiAccount.first(:conditions => ['user_id = ? AND user_name = ?', 0, SLINGGIT_HANDEL_USERNAME], :select => 'id')
    @slinggit_account_id = slinggit_api_account.blank? ? nil : slinggit_api_account.id
  end

end