class AdditionalPhotosController < ApplicationController

  def add
    if signed_in?
      if not params[:additional_photo].blank?
        if params[:post_id].length == 40
          post = Post.first(:conditions => ['id_hash = ? and user_id = ?', params[:post_id], current_user.id])
        else
          post = Post.first(:conditions => ['id = ? and user_id = ?', params[:post_id], current_user.id])
        end
        if not post.blank?
          if post.has_photo?
            additional_photo = AdditionalPhoto.new(
                :user_id => current_user.id,
                :source => 'posts',
                :source_id => post.id,
                :photo => params[:additional_photo][:photo],
                :photo_file_name => params[:additional_photo][:photo].original_filename,
                :photo_content_type => params[:additional_photo][:photo].content_type,
                :photo_file_size => params[:additional_photo][:photo].tempfile.length,
                :status => STATUS_ACTIVE
            )
            if not additional_photo.save
              flash[:error] = 'There was an error adding your photo.'
            else
              flash[:success] = 'Photo added.'
            end
          else
            post.photo = params[:additional_photo][:photo]
            if not post.save
              flash[:error] = 'There was an error adding your photo.'
            else
              flash[:success] = 'Photo added.'
            end
          end
          redirect_to :controller => :posts, :action => :show, :id => post.id_hash
        else
          flash[:error] = 'There was an error adding your photo.'
          redirect_to :controller => :posts
        end
      end
    else
      flash[:error] = 'There was an error adding your photo.'
      redirect_to :controller => :posts
    end
  end

end
