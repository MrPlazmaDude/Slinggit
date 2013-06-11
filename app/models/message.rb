# == Schema Information
#
# Table name: messages
#
#  id                :integer         not null, primary key
#  sender_user_id   :integer
#  recipient_user_id :integer
#  source            :string(255)
#  source_id         :integer
#  contact_info_json :string(255)
#  body              :string(1200)
#  status            :string(255)     default("UNR")
#  id_hash           :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  parent_source_id  :integer
#

#create_table :messages do |t|
#  t.integer :sender_user_id
#  t.integer :recipient_user_id
#  t.string :source
#  t.integer :source_id
#  t.string :contact_info_json
#  t.string :body, :limit => 1200
#  t.string :status
#  t.timestamps
#end

class Message < ActiveRecord::Base
  attr_accessible :sender_user_id, :recipient_user_id, :source, :source_id, :contact_info_json, :body, :status, :send_email, :parent_id, :thread_id, :recipient_status, :sender_status
  attr_accessor :send_email

  before_create :create_id_hash
  before_create :format_contact_info_json
  after_create :send_new_message_email

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :contact_info_json, presence: true, format: {with: VALID_EMAIL_REGEX}
  validates :body, presence: true
  validates_length_of :body, :maximum => 1000

  def contact_info
    contact_info_hash = HashWithIndifferentAccess.new
    decoded_contact_info = ActiveSupport::JSON.decode(self.contact_info_json)
    if not decoded_contact_info.blank?
      decoded_contact_info.each do |key, value|
        contact_info_hash[key] = value
      end
      return contact_info_hash
    end
    return nil
  end

  def send_new_message_email
    if send_email and EmailPreference.exists?(['user_id = ? AND system_emails = ?', self.recipient_user_id, true])
      UserMailer.new_message(self).deliver
    end
  end

  def create_id_hash
    self.id_hash = Digest::SHA1.hexdigest(self.id.to_s + Time.now.to_s)
  end

  def format_contact_info_json
    #once we allow for more contact types, add them to the hash and set up regix to find and parse each type
    self.contact_info_json = {:email => self.contact_info_json}.to_json
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

  def sender_user_name
    if not self.sender_user_id.blank?
      user = User.first(:conditions => ['id = ?', self.sender_user_id], :select => 'name')
      if not user.blank?
        return user.name
      end
    end
    return nil
  end

  def recipient_user_name
    if not self.recipient_user_id.blank?
      user = User.first(:conditions => ['id = ?', self.recipient_user_id], :select => 'name')
      if not user.blank?
        return user.name
      end
    end
    return nil
  end

  def from
    from_string = ''
    if not self.sender_user_id.blank?
      user = User.first(:conditions => ['id = ?', self.sender_user_id], :select => 'name')
      if not user.blank?
        from_string = user.name
      end
    end

    if from_string.blank?
      from_string = self.contact_info[:email]
    end

    return from_string
  end

  def thread_history(current_user)
    if not self.thread_id.blank?
      if not @messages.blank?
        return @messages
      else
        @messages = Message.all(:conditions => ['thread_id = ?', self.thread_id], :select => 'id,body,recipient_user_id,sender_user_id,created_at,contact_info_json', :order => 'id desc')
        if not @messages.blank?
          @messages.each do |message|
            if message.recipient_user_id == current_user.id
              message.update_attribute(:recipient_status, STATUS_READ)
            end
          end
          return @messages
        else
          return nil
        end
      end
    else
      return nil
    end
  end

  def last_in_thread
    if not self.thread_id.blank?
      if not @last_in_thread.blank?
        return @last_in_thread
      else
        @last_in_thread = Message.first(:conditions => ['thread_id = ?', self.thread_id], :select => 'id,body,recipient_user_id,sender_user_id,created_at', :order => 'id desc')
        return @last_in_thread
      end
    else
      return nil
    end
  end

  def delete_history(current_user, status_column)
    if not self.thread_id.blank?
      messages = Message.all(:conditions => ['thread_id = ? AND id != ?', self.thread_id, self.id], :select => 'id,body,recipient_user_id,sender_user_id,created_at')
      if not messages.blank?
        messages.each do |messages|
          messages.update_attribute(status_column, STATUS_DELETED)
        end
      end
    else
      return nil
    end
  end

end
