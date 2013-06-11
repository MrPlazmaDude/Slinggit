# == Schema Information
#
# Table name: users
#
#  id                        :integer         not null, primary key
#  name                      :string(255)
#  email                     :string(255)
#  created_at                :datetime        not null
#  updated_at                :datetime        not null
#  password_digest           :string(255)
#  remember_token            :string(255)
#  admin                     :boolean         default(FALSE)
#  status                    :string(255)     default("UVR")
#  password_reset_code       :string(255)
#  email_activation_code     :string(255)
#  time_zone                 :string(255)
#  account_reactivation_code :string(255)
#  slug                      :string(255)
#  role                      :string(255)     default("EXT")
#  photo_source              :string(255)
#

class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  attr_accessible :email, :name, :password, :password_confirmation, :remember_me, :twitter_atoken, :twitter_asecret, :status, :role, :photo_source, :account_reactivation_code
  has_secure_password
  has_many :posts, dependent: :destroy
  # not making comments dependent: :destroy because we may still want comments associated with posts
  # even if the user is destroyed.  If this is wrong, let's change it.
  has_many :comments
  has_many :watchedposts, :before_add => :validates_watchedpost, dependent: :destroy

  before_save :downcase_attributes
  before_save :create_remember_token
  after_create :create_limitation_records
  after_create :create_email_preference_record
  after_update :send_profile_update_emails

  # Allows letters, numbers and underscore
  VALID_USERNAME_REGEX = /\A[a-z0-9_-]{,20}\z/i
  validates :name, presence: true, length: {maximum: 20},
            format: {with: VALID_USERNAME_REGEX},
            uniqueness: {case_sensitive: false}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :password, length: {minimum: 6}, :if => lambda { new_record? || !password.nil? }
  validates :password_confirmation, presence: true, :if => lambda { new_record? || !password.nil? }

  def email_preferences(preference_type)
    if email_preference = EmailPreference.first(:conditions => ['user_id = ?', self.id])
      if preference_type == 'system_emails'
        return email_preference.system_emails
      elsif preference_type == 'marketing_emails'
        return email_preference.marketing_emails
      end
    else
      return false
    end
  end

  def active_post_count
    Post.count(:conditions => [' status = ? and user_id = ?', STATUS_ACTIVE, self.id], :select => 'id')
  end

  def open_post_count
    Post.count(:conditions => ['status = ? and user_id = ? and open = ?', STATUS_ACTIVE, self.id, true], :select => 'id')
  end

  def post_limit
    user_limitation = UserLimitation.first(:conditions => ['user_id = ? and limitation_type = ?', self.id, 'total_posts'], :select => 'user_limit')
    return user_limitation.user_limit
  end

  def twitter_authorized?
    !twitter_atoken.blank? && !twitter_asecret.blank?
  end

  def primary_twitter_account
    ApiAccount.first(:conditions => ['user_id = ? AND status = ? AND api_source = ?', self.id, STATUS_PRIMARY, 'twitter'], :select => 'id,user_name,image_url')
  end

  def primary_facebook_account
    ApiAccount.first(:conditions => ['user_id = ? AND status = ? AND api_source = ?', self.id, STATUS_PRIMARY, 'facebook'], :select => 'id,user_name,image_url')
  end

  def email_is_verified?
    self.email_activation_code.blank? and self.status != STATUS_UNVERIFIED
  end

  def is_admin?
    self.admin or (self.email.include? '@slinggit.com' and self.email_is_verified?)
  end

  def is_active?
    self.status == STATUS_ACTIVE
  end

  def is_considered_deleted?
    self.status == STATUS_BANNED || self.status == STATUS_DELETED
  end

  def is_self_destroyed?
    self.status == STATUS_DELETED && !self.account_reactivation_code.blank?
  end

  def is_banned?
    self.status == STATUS_BANNED && self.account_reactivation_code.blank?
  end

  def is_suspended?
    self.status == STATUS_SUSPENDED
  end

  def has_photo_source?
    not self.photo_source.blank?
  end

  def profile_photo_url
    # This insures that at least one photo url is returned
    url = "icon_blue_80x80.png"
    if self.photo_source == SLINGGIT_PHOTO_SOURCE
      #slinggit_images = ['icon_blue_80x80.png', 'icon_red_80x80.png', 'icon_green_80x80.png', 'icon_yellow_80x80.png']
      #url = slinggit_images[rand(slinggit_images.length)]
      url = 'icon_blue_80x80.png'
    elsif self.photo_source == TWITTER_PHOTO_SOURCE
      if not self.primary_twitter_account.blank?
        thumbnail_url = self.primary_twitter_account.image_url
        url = thumbnail_url.gsub('_normal', '')
      end
    elsif self.photo_source == FACEBOOK_PHOTO_SOURCE
      if not self.primary_facebook_account.blank?
        url = self.primary_facebook_account.image_url
      end
    elsif self.photo_source == GRAVATAR_PHOTO_SOURCE
      url = gravatar_img_url(self)
    end

    return url
  end

  def post_in_watch_list? post_id
    watched = self.watchedposts.first(:conditions => ['post_id = ?', post_id], :select => 'id')
    if watched.blank?
      return false
    else
      return true
    end
  end

  private

  def validates_watchedpost(watchedpost)
    watched = self.watchedposts.first(:conditions => ['user_id = ? AND post_id = ?', watchedpost.user_id, watchedpost.post_id])
    if not watched.blank?
      raise ActiveRecord::Rollback
      # TODO redirect to what are you trying to do page
    end
  end

  def gravatar_img_url(user)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://gravatar.com/avatar/#{gravatar_id}.png"
  end

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

  def send_profile_update_emails
    #TODO create email that sends out the verification link again
    if not self.changed_attributes['email'].blank?

    end

    #TODO create email that informs user of password change
    if not self.changed_attributes[:password_digest].blank?

    end
  end

  def downcase_attributes
    self.email = email.downcase
    self.name = name.downcase
  end

  def create_email_preference_record
    if not EmailPreference.exists?(['user_id = ?', self.id])
      EmailPreference.create(
          :user_id => self.id,
          :system_emails => true,
          :marketing_emails => false
      )
    end
  end

  def create_limitation_records
    #by doing limitations on a per user basis, we can provide different values for different users
    #using a system preference for the defaults will allow us to make a single database change for all new users moving forward
    #if we dont have an active preference for somereason, it will default since we clearly need something here
    default_posts_user_limit = system_preferences[:default_posts_user_limit] || '{"user_limit":"5","frequency":"","frequency_type":"at_once"}'
    decoded_default_posts_user_limit = ActiveSupport::JSON.decode(default_posts_user_limit)
    UserLimitation.create(
        :user_id => self.id,
        :limitation_type => 'total_posts',
        :user_limit => decoded_default_posts_user_limit['user_limit'],
        :frequency => decoded_default_posts_user_limit['frequency'],
        :frequency_type => decoded_default_posts_user_limit['frequency_type'],
        :active => true
    )

    default_invites_user_limit = system_preferences[:default_invites_user_limit] || '{"user_limit":"100","frequency":"","frequency_type":"at_once"}'
    decoded_default_invites_user_limit = ActiveSupport::JSON.decode(default_invites_user_limit)
    UserLimitation.create(
        :user_id => self.id,
        :limitation_type => 'total_invites',
        :user_limit => decoded_default_invites_user_limit['user_limit'],
        :frequency => decoded_default_invites_user_limit['frequency'],
        :frequency_type => decoded_default_invites_user_limit['frequency_type'],
        :active => true
    )

    default_images_per_post_user_limit = system_preferences[:default_images_per_post_limit] || '{"user_limit":"1","frequency":"","frequency_type":"at_once"}'
    decoded_default_images_per_post_user_limit = ActiveSupport::JSON.decode(default_images_per_post_user_limit)
    UserLimitation.create(
        :user_id => self.id,
        :limitation_type => 'images_per_post',
        :user_limit => decoded_default_images_per_post_user_limit['user_limit'],
        :frequency => decoded_default_images_per_post_user_limit['frequency'],
        :frequency_type => decoded_default_images_per_post_user_limit['frequency_type'],
        :active => true
    )
  end

  def system_preferences
    #we dont have access to session here so a method in this model was added
    if @system_preferences.blank?
      active_preferences = HashWithIndifferentAccess.new()
      system_preferences = SystemPreference.all(:conditions => ['active = ?', true])
      system_preferences.each do |preference|
        if (preference.start_date.blank? or preference.start_date <= Date.now) and (preference.end_date.blank? or preference.end_date >= Date.now)
          if preference.constraints.blank? or eval(preference.constraints)
            active_preferences[preference.preference_key] = preference.preference_value
          end
        end
      end
      @system_preferences = active_preferences
      return @system_preferences
    else
      return @system_preferences
    end
  end

end
