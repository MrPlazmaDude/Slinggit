class SiteDisableModes < ActiveRecord::Migration
  def up
    if not SystemPreference.exists?(['preference_key = ?', 'site_mode'])
      SystemPreference.create(
          :preference_key => 'site_mode',
          :preference_value => 'live_invitation_only',
          :constraints => 'true',
          :description => 'Valid modes: live(normal site functionality), live_invitation_only(invitaion_only screen is present in place of signup), maintenence(message that says we are currently in maintenence mode), over_capacity(message that says we are currently over capacity)',
          :active => true
      )
    end

    if system_preference = SystemPreference.first(:conditions => ['preference_key = ?', 'invitation_only'])
      system_preference.destroy
    end
  end

  def down
    system_preference = SystemPreference.first(:conditions => ['preference_key = ?', 'site_mode'])
    if not system_preference.blank?
      system_preference.destroy
    end

    if not SystemPreference.exists?(['preference_key = ?', 'invitation_only'])
      SystemPreference.create(
          :preference_key => 'invitation_only',
          :preference_value => 'off',
          :constraints => 'true',
          :description => 'if this is active, no signups will be allowed, only invitation requests.',
          :active => true
      )
    end

  end

end
