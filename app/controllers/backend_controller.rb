class BackendController < ApplicationController
  def daily_jobs
    enabled_jobs = ['comment_notifier']

    #CLOSES POSTS THAT HAVE BEEN OPEN FOR AS LONG OR LONGER THAN THE SYSTEM PREFERENCE ALLOWS
    #STATUS: DISABLED
    ############################################

    if enabled_jobs.include? 'post_monitor'
      max_days_open = system_preferences[:post_max_days_open]
      max_days_ago = Time.now.advance(:days => max_days_open.to_i * -1)
      posts_closed = 0
      posts = Post.find_each(:conditions => ['open = ? AND status = ? AND created_at < ?', true, STATUS_ACTIVE, max_days_ago], :select => 'id,status') do |post|
        posts_closed += 1
        post.update_attribute(:open, false)
      end
      UserMailer.post_monitor_report(posts_closed).deliver
    end

    ############################################

    #SENDS AN EMAIL TO USERS WHO HAVE RECEIVED COMMENTS
    #STATUS: ENABLED
    ############################################

    if enabled_jobs.include? 'comment_notifier'
      beginning_of_day = Date.today
      comments_created_today = Comment.all(:conditions => ['created_at > ?', beginning_of_day], :order => 'user_id', :select => 'post_id,user_id')
      comments_by_user = {}
      comments_created_today.each do |comment|
        post_user_id = comment.post('user_id').user_id
        if comment.user_id != post_user_id
          if comments_by_user[post_user_id]
            comments_by_user[post_user_id] << comment
          else
            comments_by_user[post_user_id] = [comment]
          end
        end
      end

      #send email to each user to inform them they have comments on their posts with links to the post
      comments_by_user.each do |user_id, todays_comments|
        if EmailPreference.exists?(['user_id = ? AND system_emails = ?', user_id, true])
          UserMailer.comment_notifier(user_id, todays_comments).deliver
        end
      end
    end

    ############################################

    render :nothing => true
  end
end
