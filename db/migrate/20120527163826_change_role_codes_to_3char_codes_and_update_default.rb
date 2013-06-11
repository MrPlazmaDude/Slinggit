class ChangeRoleCodesTo3charCodesAndUpdateDefault < ActiveRecord::Migration
  
  class User < ActiveRecord::Base
     attr_accessible :role
  end

  def up
  	change_column_default(:users, :role, 'EXT')
  	User.reset_column_information
  	User.all.each do |user|
  		if user.role == "external"
  			user.update_attribute(:role, "EXT")
  		elsif user.role == "admin"
  			user.update_attribute(:role, "ADM")
  		end	
  	end
  end

  def down
  	change_column_default(:users, :role, 'external')
  	User.reset_column_information
  	User.all.each do |user|
  		if user.role == "EXT"
  			user.update_attribute(:role, "external")
  		elsif user.role == "ADM"
  			user.update_attribute(:role, "admin")
  		end	
  	end
  end
end
