# == Schema Information
#
# Table name: redirects
#
#  id         :integer         not null, primary key
#  key_code   :string(255)
#  target_uri :string(255)
#  clicks     :integer         default(0)
#  active     :boolean         default(TRUE)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Redirect < ActiveRecord::Base
  attr_accessible :target_uri, :clicks

  before_create :create_hash

  def self.get_or_create(options = {})
    if redirect = Redirect.first(:conditions => ['target_uri = ?', options[:target_uri]])
      return redirect
    else
      redirect = Redirect.create(options.merge!(:clicks => 0))
      return redirect
    end
  end

  def create_hash
    if self.target_uri and self.target_uri.length > 0
      for attempt in 1..20
        hashed_url = Digest::SHA1.hexdigest(self.target_uri.strip)[0,3 + attempt]
        if not Redirect.exists?(["key_code = ?", hashed_url])
          self.key_code = hashed_url
          return hashed_url
        elsif attempt == 20
          return nil
        end
      end
    end
  end

  def get_short_url
    return "#{BASEURL}/#{self.key_code}"
  end

end
