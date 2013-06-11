class WatchedpostsController < ApplicationController
	def interested
		post = params[:post]
		@watchedpost = current_user.watchedposts.build(:post_id => post)
		if @watchedpost.save
			redirect_to post_path(post)
		else
			flash[:notice] = "We're experiencing technical difficulties.  Please try again shortly."
			redirect_to post_path(post)
		end
	end

	def uninterested
		post = params[:post]
		@watchedpost = current_user.watchedposts.first(:conditions => ['user_id = ? AND post_id = ?', current_user.id, post])
		if not @watchedpost.blank?
			@watchedpost.destroy
			redirect_to post_path(post)
		end
	end
end
