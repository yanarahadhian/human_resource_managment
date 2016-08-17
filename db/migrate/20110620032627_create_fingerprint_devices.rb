class CreateFingerprintDevices < ActiveRecord::Migration
  def self.up
    create_table :fingerprint_devices do |t|
      t.string :ip_address
      t.integer :port
      t.string :device_name
      t.timestamps
    end
  end

  def self.down
    drop_table :fingerprint_devices
  end
end

