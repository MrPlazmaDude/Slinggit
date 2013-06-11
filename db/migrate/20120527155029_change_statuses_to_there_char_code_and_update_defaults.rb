class ChangeStatusesToThereCharCodeAndUpdateDefaults < ActiveRecord::Migration
  
  class User < ActiveRecord::Base
     attr_accessible :status
  end	

  class Post < ActiveRecord::Base
    attr_accessible :status
  end	

  class Comment < ActiveRecord::Base
    attr_accessible :status
  end


  def up
  	change_column_default(:users, :status, 'UVR')
  	change_column_default(:comments, :status, 'ACT')
  	change_column_default(:posts, :status, 'ACT')

  	User.reset_column_information
  	User.all.each do |user|
  		if user.status == 'unverified'
  			user.update_attribute(:status, "UVR")
  		elsif user.status == 'active'
  			user.update_attribute(:status, "ACT")
  		elsif user.status == 'suspended'
  			user.update_attribute(:status, "SUS")
  		elsif user.status == 'banned'
  			user.update_attribute(:status, "BAN")
  		elsif user.status == 'deleted'
  			user.update_attribute(:status, "DEL")
  		end
  	end

  	Post.reset_column_information
  	Post.all.each do |post|
  		if post.status == 'active'
  			post.update_attribute(:status, "ACT")
  		elsif post.status == 'deleted'
  			post.update_attribute(:status, "DEL")
  		elsif post.status == 'suspended'
  			post.update_attribute(:status, "SUS")
  		elsif post.status == 'banned'
  			post.update_attribute(:status, "BAN")
  		end
  	end

  	Comment.reset_column_information
  	Comment.all.each do |comment|
  		if comment.status == 'active'
  			comment.update_attribute(:status, "ACT")
  		elsif comment.status == 'deleted'
  			comment.update_attribute(:status, "DEL")
  		elsif comment.status == 'suspended'
  			comment.update_attribute(:status, "SUS")
  		elsif comment.status == 'banned'
  			comment.update_attribute(:status, "BAN")
  		end
  	end

  end

  def down
  	change_column_default(:users, :status, 'unverified')
  	change_column_default(:comments, :status, 'active')
  	change_column_default(:posts, :status, 'active')

  	User.reset_column_information
  	User.all.each do |user|
  		if user.status == 'UVR'
  			user.update_attribute(:status, "unverified")
  		elsif user.status == 'ACT'
  			user.update_attribute(:status, "active")
  		elsif user.status == 'SUS'
  			user.update_attribute(:status, "suspended")
  		elsif user.status == 'BAN'
  			user.update_attribute(:status, "banned")
  		elsif user.status == 'DEL'
  			user.update_attribute(:status, "deleted")
  		end
  	end

  	Post.reset_column_information
  	Post.all.each do |post|
  		if post.status == 'ACT'
  			post.update_attribute(:status, "active")
  		elsif post.status == 'DEL'
  			post.update_attribute(:status, "deleted")
  		elsif post.status == 'SUS'
  			post.update_attribute(:status, "suspended")
  		elsif post.status == 'BAN'
  			post.update_attribute(:status, "banned")
  		end
  	end

  	Comment.reset_column_information
  	Comment.all.each do |comment|
  		if comment.status == 'ACT'
  			comment.update_attribute(:status, "active")
  		elsif comment.status == 'DEL'
  			comment.update_attribute(:status, "deleted")
  		elsif comment.status == 'SUS'
  			comment.update_attribute(:status, "suspended")
  		elsif comment.status == 'BAN'
  			comment.update_attribute(:status, "banned")
  		end
  	end

  end

end
