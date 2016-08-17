class AddDeviceUserIdToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :fingerprint_user, :integer
    add_column :people, :fingerprint_device_id, :integer
  end

  def self.down
    remove_column :people, :fingerprint_user
    remove_column :people, :fingerprint_device_id
  end
end

