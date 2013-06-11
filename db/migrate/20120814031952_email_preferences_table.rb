class EmailPreferencesTable < ActiveRecord::Migration
  def up

    create_table :email_preferences do |t|
      t.integer :user_id
      t.boolean :system_emails
      t.boolean :marketing_emails
    end

    users = User.all(:select => 'id')
    users.each do |user|
      if not EmailPreference.exists?(['user_id = ?', user.id])
        EmailPreference.create(
            :user_id => user.id,
            :system_emails => true,
            :marketing_emails => false
        )
      end
    end
  end

  def down
    drop_table :email_preferences
  end
end
