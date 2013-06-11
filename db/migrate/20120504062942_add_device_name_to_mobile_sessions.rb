class AddDeviceNameToMobileSessions < ActiveRecord::Migration
  def change
    add_column :mobile_sessions, :device_name, :string, :defailt => 'mobile device'
    add_column :mobile_sessions, :ip_address, :string
    add_column :mobile_sessions, :options, :string, :limit => 1000
  end
end
