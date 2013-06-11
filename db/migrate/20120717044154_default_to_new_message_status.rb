class DefaultToNewMessageStatus < ActiveRecord::Migration
  def up
    change_column :messages, :recipient_status, :string, :default => 'UNR'
    change_column :messages, :sender_status, :string, :default => 'UNR'
  end

  def down
  end
end
