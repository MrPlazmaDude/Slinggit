class PostLimitationUpdate < ActiveRecord::Migration
  def up

    #these dont get used yet... I will add preference when they are used... in the mean time, defaults are used
    if system_preference1 = SystemPreference.first(:conditions => ['preference_key = ?', 'default_invites_user_limit'])
      system_preference1.destroy
    end

    if system_preference2 = SystemPreference.first(:conditions => ['preference_key = ?', 'default_images_per_post_limit'])
      system_preference2.destroy
    end

    if system_preference2 = SystemPreference.first(:conditions => ['preference_key = ?', 'default_post_length_user_limit'])
      system_preference2.destroy
    end

    if system_preference = SystemPreference.first(:conditions => ['preference_key = ?', 'default_posts_user_limit'])
      system_preference.preference_value = '{"user_limit":"5","frequency":"","frequency_type":"at_once"}'
      system_preference.save
    else
      SystemPreference.create(
          :preference_key => 'default_posts_user_limit',
          :preference_value => '{"user_limit":"5","frequency":"","frequency_type":"at_once"}',
          :constraints => 'true',
          :description => 'this preference is used to define the default number of posts we allow per user when a user is created.  In this case... 5 at one time',
          :active => true
      )
    end

    SystemPreference.create(
        :preference_key => 'post_max_days_open',
        :preference_value => '10',
        :constraints => 'true',
        :description => 'this preference is used by the post monitor to close posts that have been opened longer than this preference',
        :active => true
    )

    UserLimitation.update_all("limitation_type = 'total_invites'", "limitation_type = 'invites'")
    UserLimitation.update_all("limitation_type = 'total_posts'", "limitation_type = 'posts'")
  end

  def down
    if system_preference = SystemPreference.first(:conditions => ['preference_key = ?', 'default_posts_user_limit'])
      system_preference.preference_value = '{"user_limit":"10","frequency":"24","frequency_type":"hours"}'
      system_preference.save
    end
  end
end
