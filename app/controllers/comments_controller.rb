class CommentsController < ApplicationController

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.new(params[:comment])
    if @comment.save
      # We'll assume that a user that creates a comment is interested in the item and is not the owner of the post
      if current_user.id != @post.user_id
        watchedpost = current_user.watchedposts.build(:post_id => @post.id) unless current_user.post_in_watch_list?(@post.id)
        watchedpost.save unless watchedpost.blank?
      end
    else
      flash[:error] = "Comments can only be 300 characters"
    end
    redirect_to post_path(@post)
  end

  def delete
    if comment = Comment.first(:conditions => ['id_hash = ?', params[:id]], :select => 'id,status,user_id')
      if signed_in? and (current_user.id == comment.user_id or current_user.id == comment.post('user_id').user_id)
        comment.update_attribute(:status, STATUS_DELETED)
        flash[:success] = "Comment deleted"
      end
    end
    if not request.referer.blank?
      redirect_to request.referer
    else
      redirect_to post_path
    end
  end

end
