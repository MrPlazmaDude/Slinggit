class MaxPhotosPerPostSystemPreference < ActiveRecord::Migration
  def up
    SystemPreference.create(
        :preference_key => 'default_images_per_post_limit',
        :preference_value => '{"user_limit":"1","frequency":"0","frequency_type":"0"}',
        :constraints => 'true',
        :description => 'this preference is used to define the default number of images we allow per post, per user, when a user is created.',
        :active => true
    )
  end

  def down
    if system_preference = SystemPreference.first(:conditions => ['preference_key = ?', 'default_images_per_post_limit'])
      system_preference.destroy
    end
  end
end
