class StartingSystemPreferences < ActiveRecord::Migration
  def up

    #adding unique key to preference_key for obvious reasons
    add_index(:system_preferences, :preference_key, :unique => true)

    #fixing slight mess up where I passed true to constraints instead of 'true'
    #constraints are evald so it requires a string and I dont want the string to be t when it needs to be true.
    if system_preference = SystemPreference.first(:conditions => ['preference_key = ?', "invitation_only"])
      system_preference.destroy
    end

    SystemPreference.create(
        :preference_key => 'invitation_only',
        :preference_value => 'off',
        :constraints => 'true',
        :description => 'if this is active, no signups will be allowed, only invitation requests.',
        :active => true
    )

    SystemPreference.create(
        :preference_key => 'default_invites_user_limit',
        :preference_value => '{"user_limit":"100","frequency":"0","frequency_type":"0"}',
        :constraints => 'true',
        :description => 'this preference is used to define the default number of invites we allow per user when a user is created.',
        :active => true
    )

    SystemPreference.create(
        :preference_key => 'default_posts_user_limit',
        :preference_value => '{"user_limit":"10","frequency":"24","frequency_type":"hours"}',
        :constraints => 'true',
        :description => 'this preference is used to define the default number of posts we allow per user when a user is created.',
        :active => true
    )
  end

  def down

    if system_preference = SystemPreference.first(:conditions => ['preference_key = ?', "invitation_only"])
      system_preference.destroy
    end
    if system_preference = SystemPreference.first(:conditions => ['preference_key = ?', "default_invites_user_limit"])
      system_preference.destroy
    end
    if system_preference = SystemPreference.first(:conditions => ['preference_key = ?', "default_posts_user_limit"])
      system_preference.destroy
    end

  end
end
