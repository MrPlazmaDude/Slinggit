module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Slinggit"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def system_preferences
    #TODO remove true from the following line after presentation.  Dont want the invitation only session to get bogged up during pres
    if true or session[:system_preferences].blank?
      active_preferences = HashWithIndifferentAccess.new()
      system_preferences = SystemPreference.all(:conditions => ['active = ?', true])
      system_preferences.each do |preference|
        if (preference.start_date.blank? or preference.start_date <= Date.now) and (preference.end_date.blank? or preference.end_date >= Date.now)
          if preference.constraints.blank? or eval(preference.constraints)
            active_preferences[preference.preference_key] = preference.preference_value
          end
        end
      end
      session[:system_preferences] = active_preferences
      return active_preferences
    else
      return session[:system_preferences]
    end
  end

  def invite_only?
    if system_preferences[:invitation_only] and system_preferences[:invitation_only] == "on"
      return true
    else
      return false
    end
  end

end

