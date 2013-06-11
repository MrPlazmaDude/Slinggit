class AddRoleToUsers < ActiveRecord::Migration

  class User < ActiveRecord::Base
	attr_accessible :role
  end

  def change
  	add_column :users, :role, :string, :default => 'external'
  	User.reset_column_information
  	User.all.each do |user|
  		if user.admin?
  			user.update_attributes!(:role => 'admin')
  		else
  			user.update_attributes!(:role => 'external')
  		end
  	end
  end

end
