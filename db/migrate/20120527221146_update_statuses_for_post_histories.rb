class UpdateStatusesForPostHistories < ActiveRecord::Migration

  class PostHistory < ActiveRecord::Base
  	attr_accessible :status
  end

  def up
  	PostHistory.reset_column_information
  	PostHistory.all.each do |post_history|
  		if post_history.status == 'active'
  			PostHistory.update_all("status = 'ACT'", "id = #{post_history.id}")
  		elsif post_history.status == 'deleted'
  			PostHistory.update_all("status = 'DEL'", "id = #{post_history.id}")
  		elsif post_history.status == 'suspended'
  			PostHistory.update_all("status = 'SUS'", "id = #{post_history.id}")
  		elsif post_history.status == 'banned'
  			PostHistory.update_all("status = 'BAN'", "id = #{post_history.id}")
  		end
  	end
  end

  def down
  	PostHistory.reset_column_information
  	PostHistory.all.each do |post_history|
  		if post_history.status == 'ACT'
  			PostHistory.update_all("status = 'active'", "id = #{post_history.id}")
  		elsif post_history.status == 'DEL'
  			PostHistory.update_all("status = 'deleted'", "id = #{post_history.id}")
  		elsif post_history.status == 'SUS'
  			PostHistory.update_all("status = 'suspended'", "id = #{post_history.id}")
  		elsif post_history.status == 'BAN'
  			PostHistory.update_all("status = 'banned'", "id = #{post_history.id}")
  		end
  	end
  end
end
