# == Schema Information
#
# Table name: comments
#
#  id         :integer         not null, primary key
#  body       :text
#  post_id    :integer
#  user_id    :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  status     :string(255)     default("ACT")
#

class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
  attr_accessible :body, :user_id, :post_id, :status

  before_create :create_id_hash

  validates :body, presence: true, length: {maximum: 300}

  default_scope order: 'comments.created_at DESC'

  def create_id_hash
    self.id_hash = Digest::SHA1.hexdigest(self.id.to_s + Time.now.to_s)
  end

  def post(fields = '*')
    Post.first(:conditions => ['id = ?', self.post_id], :select => fields)
  end
end
