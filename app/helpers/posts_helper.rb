module PostsHelper

	def get_post_link(post, network_posts, source)
		return nil if not network_posts.any?
		post_to_link_to = nil

		# Iterate through posts and see if one is tied to the 
		# primary account first.
        network_posts.each do |network_post|
          if not network_post.primary_account.blank?
          	post_to_link_to = network_post unless network_post.status != STATUS_SUCCESS
			break 	
          end
        end

        # If primary account wasn't posted to, find one that is
        # or return nil
        if post_to_link_to.blank?
        	if source == 'twitter'
        		post_to_link_to = TwitterPost.first(:conditions => ['post_id = ? AND user_id = ? AND status = ?', post.id, post.user_id, STATUS_SUCCESS], order: "created_at DESC")
        	elsif source == 'facebook'
        		post_to_link_to = FacebookPost.first(:conditions => ['post_id = ? AND user_id = ? AND status = ?', post.id, post.user_id, STATUS_SUCCESS], order: "created_at DESC")
        	end
        end

        return post_to_link_to
	end

end