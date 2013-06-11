class Watchedpost < ActiveRecord::Base
  attr_accessible :post_id
  belongs_to :user
end
