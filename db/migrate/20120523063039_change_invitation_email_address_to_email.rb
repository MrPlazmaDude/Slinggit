class ChangeInvitationEmailAddressToEmail < ActiveRecord::Migration
  def up
    rename_column :invitations, :email_address, :email
    remove_column :invitations, :location

    add_column :invitations, :source_user_id, :integer
    add_column :invitations, :activation_code, :string
  end

  def down
    rename_column :invitations, :email, :email_address
    add_column :invitations, :location, :string

    remove_column :invitations, :source_user_id
    remove_column :invitations, :activation_code
  end
end
