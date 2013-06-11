class InvitationsTable < ActiveRecord::Migration
  def up
    create_table :invitations do |t|
      t.string :email_address
      t.string :location
      t.text :comment
      t.string :status, :default => 'pending'
      t.timestamps
    end

    create_table :system_preferences do |t|
      t.string :preference_key
      t.string :preference_value
      t.string :constraints
      t.string :description
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :active, :default => false
    end

    SystemPreference.create(
      :preference_key => 'invitation_only',
      :preference_value => 'on',
      :constraints => true,
      :description => 'if this is active, passes constraints and is within the start and end date (assuming present)... the invitation only screen will be present instead of the signup screen.',
      :start_date => nil,
      :end_date => nil,
      :active => true
    )

  end

  def down
    drop_table :system_preferences
    drop_table :invitations
  end
end
