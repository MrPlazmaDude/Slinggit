class AddPhotoSourceToUser < ActiveRecord::Migration
  class User < ActiveRecord::Base
     attr_accessible :photo_source
  end

  def up
  	add_column :users, :photo_source, :string
  	User.reset_column_information
  	User.all.each do |user|
  		if user.photo_source == nil
  			user.update_attribute(:photo_source, "GPS")
  		end	
  	end
  end

  def down
  	remove_column :users, :photo_source
  end	
end
