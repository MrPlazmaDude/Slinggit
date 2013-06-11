class MessagesController < ApplicationController
  before_filter :signed_in_user, :except => [:new, :create]
  before_filter :user_verified, only: [:index, :show, :new, :create, :delete, :reply]

  def index
    @messages = Message.paginate(page: params[:page], :per_page => 10, :conditions => ['recipient_user_id = ? AND status != ? AND recipient_status != ?', current_user.id, STATUS_ARCHIVED, STATUS_DELETED], :order => 'id desc, status desc', :select => 'thread_id,id,id_hash,body,recipient_status,source_id,source,created_at')
    @unread = Message.count(:conditions => ['recipient_user_id = ? AND recipient_status = ?', current_user.id, STATUS_UNREAD])
  end

  def sent
    @messages = Message.paginate(page: params[:page], :per_page => 10, :conditions => ['sender_user_id = ? AND status != ? AND sender_status != ?', current_user.id, STATUS_ARCHIVED, STATUS_DELETED], :order => 'id desc, status desc', :select => 'thread_id,id,id_hash,body,recipient_status,source_id,source,created_at')
  end

  def show
    if not params[:id].blank?
      if @message = Message.first(:conditions => ['id_hash = ? AND (recipient_user_id = ? or sender_user_id = ?) AND status = ?', params[:id], current_user.id, current_user.id, STATUS_ACTIVE], :select => 'id,status,body,created_at,id_hash,contact_info_json,sender_user_id,source_id,source,thread_id,recipient_user_id')
        if @message.recipient_user_id == current_user.id
          @message.update_attribute(:recipient_status, STATUS_READ)
        end
      else
        flash[:error] = "Message not found"
      end
    end
  end

  def reply
    @message ||= Message.new

    if not params[:id].blank?
      session.delete(:parent_message)
      if parent_message = Message.first(:conditions => ['id_hash = ? and recipient_user_id = ? AND status != ?', params[:id], current_user.id, STATUS_DELETED])
        @parent_message = parent_message
        session[:parent_message_id_hash] = parent_message.id_hash
      end
    elsif not session[:parent_message_id_hash].blank?
      if parent_message = Message.first(:conditions => ['id_hash = ? and recipient_user_id = ? AND status != ?', session[:parent_message_id_hash], current_user.id, STATUS_DELETED])
        @parent_message = parent_message
      else
        #TODO redirect to report an issue
        flash[:error] = 'You appear to be doing something we are not familiar with.  Please let us know what it is you were trying to do.'
        redirect_to root_path
      end
    else
      flash[:error] = "Sorry, we couldn't find the message you were trying to reply to."
      redirect_to message_path
    end
  end

  def new
    @message ||= Message.new

    #if they hit this account we know they arent replying
    session.delete(:parent_message_id_hash)

    #this is used to populate what they had entered before we detected that the email address they entered was already registered.  (not signed in user))
    if not session[:message_data_before_login].blank?
      @email_entered = session[:message_data_before_login][:email]
      @message_entered = session[:message_data_before_login][:body]
      session.delete(:message_data_before_login)
    end

    if not params[:id].blank?
      session.delete(:message_post_id_hash)
      if post = Post.first(:conditions => ['id_hash = ? AND status != ? AND open = ?', params[:id], [STATUS_DELETED], true])
        if not signed_in? or (signed_in? and not post.user_id == current_user.id)
          @post = post
          session[:message_post_id_hash] = post.id_hash
        else
          flash[:error] = "I'm gonna take a shot in the dark here and assume you didn't really want to send a message to your self."
          redirect_to current_user and return
        end
      end
    elsif not session[:message_post_id_hash].blank?
      if post = Post.first(:conditions => ['id_hash = ? AND status != ? AND open = ?', session[:message_post_id_hash], [STATUS_DELETED], true])
        @post = post
      else
        #TODO redirect to report an issue
        flash[:error] = 'You appear to be doing something we are not familiar with.  Please let us know what it is you were trying to do.'
        redirect_to root_path
      end
    else
      flash[:error] = 'Sad news, the post you are trying to reply to has either been closed or deleted.'
      redirect_to root_path and return
    end
  end

  def create
    if request.post?
      if session[:parent_message_id_hash]
        if params[:message]
          parent_message = Message.first(:conditions => ['id_hash = ? and recipient_user_id = ? AND status != ?', session[:parent_message_id_hash], current_user.id, STATUS_DELETED])
          @message = Message.new(params[:message])
          @mesender_user_idser_id = current_user.id
          @message.recipient_user_id = parent_message.sender_user_id
          @message.sender_user_id = current_user.id
          @message.source = parent_message.source
          @message.source_id = parent_message.source_id
          @message.contact_info_json = current_user.email
          @message.thread_id = parent_message.thread_id
          @message.status = STATUS_ACTIVE
          @message.recipient_status = STATUS_UNREAD
          @message.sender_status = STATUS_UNREAD
          @message.send_email = true

          if @message.save
            parent_message.update_attribute(:status, STATUS_ARCHIVED)
            flash[:success] = "Message has been sent."
            session.delete(:parent_message_id_hash)
            redirect_to :controller => :messages, :action => :sent
          else
            @parent_message = parent_message
            @message = Message.new(params[:message])
            render 'reply'
          end
        else
          #TODO redirect to report an issue
          flash[:error] = 'You appear to be doing something we are not familiar with.  Please let us know what it is you were trying to do.'
          redirect_to root_path
        end
      else
        if session[:message_post_id_hash]
          if params[:message]
            message_post = Post.first(:conditions => ['id_hash = ? AND status != ? AND open = ?', session[:message_post_id_hash], [STATUS_DELETED], true])
            @message = Message.new(params[:message])
            if signed_in?
              @message.contact_info_json = current_user.email
            elsif not @message.contact_info_json.blank?
              #the above if elsif statment is invalid once we start collecting additional contect info
              #this will need to rip the email field out first then validate it.
              if user = User.first(:conditions => ['email = ?', @message.contact_info_json], :select => 'email')
                flash[:notice] = "The email you provided belongs to a registered Slinggit user.  Please sign in first."
                session[:return_to] = url_for :controller => :messages, :action => :new, :id => message_post.id_hash
                session[:message_data_before_login] = {:email => @message.contact_info_json, :body => @message.body}
                redirect_to :controller => :sessions, :action => :new, :email => user.email and return
              end
            end

            thread_id = Digest::SHA1.hexdigest(SLINGGIT_SECRET_HASH + message_post.id.to_s + message_post.user_id.to_s) + (signed_in? ? "_#{current_user.id}" : "_un")
            @message.sender_user_id = signed_in? ? current_user.id : nil
            @message.recipient_user_id = message_post.user_id
            @message.source = 'post'
            @message.source_id = message_post.id
            @message.thread_id = thread_id
            @message.status = STATUS_ACTIVE
            @message.recipient_status = STATUS_UNREAD
            @message.sender_status = STATUS_UNREAD
            @message.send_email = true

            if signed_in?
              last_message_from_user = Message.last(:conditions => ['status = ? AND thread_id = ? AND sender_user_id = ?', STATUS_ACTIVE, thread_id, current_user.id], :select => 'id,status')
            end

            if @message.save
              if not last_message_from_user.blank?
                last_message_from_user.update_attribute(:status, STATUS_ARCHIVED)
              end
              flash[:success] = "Message has been sent."
              session.delete(:message_post_id_hash)
              if signed_in?
                watchedpost = current_user.watchedposts.build(:post_id => message_post.id) unless current_user.post_in_watch_list?(message_post.id)
                watchedpost.save unless watchedpost.blank?
                redirect_to :controller => :messages, :action => :sent
              else
                if not request.referer.blank?
                  redirect_to request.referer
                else
                  redirect_to root_path
                end
              end
            else
              @post = message_post
              render 'new'
            end
          else
            #TODO redirect to report an issue
            flash[:error] = 'You appear to be doing something we are not familiar with.  Please let us know what it is you were trying to do.'
            redirect_to root_path
          end
        else
          #TODO redirect to report an issue
          flash[:error] = 'You appear to be doing something we are not familiar with.  Please let us know what it is you were trying to do.'
          redirect_to root_path
        end
      end
    end
  end

  #TODO ajaxify these methods
  def delete
    if not params[:id].blank?
      if message = Message.first(:conditions => ['id_hash = ? AND (recipient_user_id = ? or sender_user_id = ?)', params[:id], current_user.id, current_user.id], :select => 'id,recipient_status,sender_status,recipient_user_id,thread_id')
        if message.recipient_user_id == current_user.id
          message.update_attribute(:recipient_status, STATUS_DELETED)
          message.delete_history(current_user, :recipient_status)
          flash[:success] = "Message deleted"
          redirect_to :action => :index
        else
          message.update_attribute(:sender_status, STATUS_DELETED)
          message.delete_history(current_user, :sender_status)
          flash[:success] = "Message deleted"
          redirect_to :action => :sent
        end
      else
        flash[:error] = "Message not found"
      end
    end
  end

  def delete_all
    if not params[:message_ids].blank?
      params[:message_ids].split(',').each do |message_id_hash|
        if message = Message.first(:conditions => ['id_hash = ? AND (recipient_user_id = ? or sender_user_id = ?)', message_id_hash, current_user.id, current_user.id], :select => 'id,recipient_status,sender_status,recipient_user_id,thread_id')
          if message.recipient_user_id == current_user.id
            @action = :index
            message.update_attribute(:recipient_status, STATUS_DELETED)
          else
            @action = :index
            message.update_attribute(:sender_status, STATUS_DELETED)
          end
        end
      end
    end
    flash[:success] = "Messages deleted"
    redirect_to :action => @action
  end
end
