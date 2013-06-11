module UsersHelper

  # Returns the Gravatar (http://gravatar.com/) for the given user.
  # HEADS UP!! The id for the image tag is needed!
  def gravatar_for(user)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://gravatar.com/avatar/#{gravatar_id}.png"
    image_tag(gravatar_url, alt: user.name , id: "GPS", class: "gravatar", :height => "auto", :width => "100%", :style => "max-width: 80px;")
  end

  # Generic method for creating post feeds to be shown on the user show page.  
  # Might even be able to abstract this to application helper something so
  # that it can be used with seaches and what not.
  def get_posts_for_user filter, page, per_page, user_id, status, open
    if filter == "open"
      @posts = Post.paginate(page: page, :per_page => per_page, :conditions => ['user_id = ? AND status = ? AND open = ?', user_id, status, open])
    elsif filter == "watched"
      @posts = []
      Watchedpost.find_each(:conditions => ['user_id = ?', user_id], :select => 'post_id') do |watched_post|
        @posts << Post.first(:conditions => ['id = ?', watched_post.post_id])
      end
      @posts = @posts.paginate(:page => params[:page], :per_page => 20)
    elsif filter == "archived"
      @posts = Post.paginate(page: params[:page], :per_page => 20, :conditions => ['user_id = ? AND status = ? AND open = ?', user_id, STATUS_ACTIVE, false]) 
    else

    end
  end

end
