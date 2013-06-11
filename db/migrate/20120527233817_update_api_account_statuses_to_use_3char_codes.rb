class UpdateApiAccountStatusesToUse3charCodes < ActiveRecord::Migration

  class ApiAccount < ActiveRecord::Base
     attr_accessible :status
  end	

  def up
  	ApiAccount.reset_column_information
  	ApiAccount.all.each do |api_account|
  		if api_account.status == 'active'
  			api_account.update_attribute(:status, "ACT")
  		elsif api_account.status == 'deleted'
  			api_account.update_attribute(:status, "DEL")
  		elsif api_account.status == 'primary'
  			api_account.update_attribute(:status, "PRM")
  		end
  	end
  end

  def down
  	ApiAccount.reset_column_information
  	ApiAccount.all.each do |api_account|
  		if api_account.status == 'ACT'
  			api_account.update_attribute(:status, "active")
  		elsif api_account.status == 'DEL'
  			api_account.update_attribute(:status, "deleted")
  		elsif api_account.status == 'PRM'
  			api_account.update_attribute(:status, "primary")
  		end
  	end
  end
end
