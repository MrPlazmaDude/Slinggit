# == Schema Information
#
# Table name: posts
#
#  id                        :integer         not null, primary key
#  content                   :string(255)
#  user_id                   :integer
#  created_at                :datetime        not null
#  updated_at                :datetime        not null
#  photo_file_name           :string(255)
#  photo_content_type        :string(255)
#  photo_file_size           :integer
#  photo_updated_at          :datetime
#  hashtag_prefix            :string(255)
#  price                     :integer(8)
#  open                      :boolean         default(TRUE)
#  location                  :string(255)
#  recipient_api_account_ids :string(255)
#  status                    :string(255)     default("ACT")
#  id_hash                   :string(255)
#

class Post < ActiveRecord::Base
  before_save :create_post_history

  before_create :create_id_hash

  attr_accessible :content, :user_id, :photo, :hashtag_prefix, :location, :price, :open, :status, :id_hash, :closing_reason

  belongs_to :user
  has_many :comments, dependent: :destroy

  has_attached_file :photo, styles: {:medium => "300x300>", :search => '80x80>'},
                    :convert_options => {
                      :medium => "-auto-orient",
                      :search => "-auto-orient" },
                    url: "#{POST_PHOTO_URL}/posts/:id/:style/:basename.:extension",
                    path: "#{POST_PHOTO_DIR}/posts/:id/:style/:basename.:extension"
  VALID_LOCATION_REGEX = /\A[a-z0-9]{,20}\z/i #We may want to force either numbers or letters at a later date
  validates :location, length: {maximum: 16}, format: {with: VALID_LOCATION_REGEX, :message => "cannot contain spaces"}
  validates :content, presence: true, length: {maximum: 300}
  validates :user_id, presence: true
  VALID_HASHTAG_REGEX = /\A[a-z0-9_]{,20}\z/i
  validates :hashtag_prefix, presence: true, length: {maximum: 15}, format: {with: VALID_HASHTAG_REGEX, :message => "(Item) cannot contain spaces.  Characters must be either a-z, 0-9, or _"}
  #VALID_PRICE_REGEX = /\A[0-9]{,20}\z/i
  validates :price, presence: true, :numericality => { :only_integer => true, :message => "must be a number and cannot be longer than 5 characters" }
  #validates_attachment_presence :photo
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'image/pjpeg', 'image/x-png']

  default_scope order: 'posts.created_at DESC'

  def create_post_history
    if not self.id.blank?
      current_post_before_save = Post.first(:conditions => ['id = ?', self.id])
      if current_post_before_save
        PostHistory.create(current_post_before_save.attributes)
      end
    end
  end

  def create_id_hash
    self.id_hash = Digest::SHA1.hexdigest(self.id.to_s + Time.now.to_s)
  end

  def price=(num)
    if not num.blank?
      # strip commas
      num.gsub!(',','') if num.is_a?(String)
      # then check if the string is an int
      if !!(num =~ /^[-+]?[0-9]+$/)
        self[:price] = num.to_i 
      end  
    end
  end 

  def hashtag_prefix=(prefix)
    prefix.gsub!(' ', '') if prefix.is_a?(String)
    self[:hashtag_prefix] = prefix
  end

  def location=(loc)
    loc.gsub!(' ', '') if loc.is_a?(String)
    self[:location] = loc
  end

  def root_photo_path
    "#{POST_PHOTO_DIR}/posts/#{self.id}"
  end

  def root_url_path
    "#{POST_PHOTO_URL}/posts/#{self.id}"
  end  

  def is_active?
    self.status == STATUS_ACTIVE
  end  

  def is_banned?
    self.status == STATUS_BANNED
  end

  def is_deleted?
    self.status == STATUS_DELETED
  end

  def has_photo?
    if self.photo_file_name.blank? or self.photo.url.include? '/missing.png'
      return false
    else
      return true
    end
  end

  def post_medium_image_src
    return self.photo_file_name.blank? ? "/assets/noPhoto_80x80.png" : self.photo.url(:medium)
  end

  def interested
    Watchedpost.count(:conditions => ['post_id = ?', self.id], :select => 'id')
  end

  def open_class
    "transparent_background" if not self.open?
  end

  def additional_photos
    photo_urls = []
    additional_photos = AdditionalPhoto.all(:conditions => ['source = ? AND source_id = ?', 'posts', self.id], :select => 'photo_file_name,photo_updated_at,id')
    if not additional_photos.blank?
      additional_photos.each do |additional_photo|
        photo_urls << additional_photo.photo.url(:medium)
      end
    end
    return photo_urls
  end

end
