# == Schema Information
#
# Table name: flagged_contents
#
#  id              :integer         not null, primary key
#  creator_user_id :integer
#  source  :string(255)
#  source_id      :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

class FlaggedContent < ActiveRecord::Base
  attr_accessible :creator_user_id, :source, :source_id
  after_create :send_email_to_execs

  def send_email_to_execs
    UserMailer.flagged_content_notification(self).deliver
  end

  def source_object(fields_to_select = nil)
    #to utalize this method the source for the record needs to represent a table model in its lower case singular form
    #example -- post, post_history, api_account
    #if it doesnt, it wont break, but it will just return nil
    if not @source_object.blank?
      return @source_object
    else
      if not self.source_id.blank?
        source_as_model = self.source.split('_').map { |x| x.titleize }.join
        begin
          query = "#{source_as_model}.first(:conditions => ['id = ?', #{self.source_id}]"
          if not fields_to_select.blank?
            if fields_to_select[:table] and fields_to_select[:columns]
              if fields_to_select[:table] == source_as_model
                query << ", :select => '#{fields_to_select[:columns]}'"
              end
            end
          end
          query << ")"
          @source_object = eval(query)
          return @source_object
        rescue
          return nil
        end
      end
    end
  end

end
