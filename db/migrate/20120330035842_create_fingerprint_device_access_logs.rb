class CreateFingerprintDeviceAccessLogs < ActiveRecord::Migration
  def self.up
    create_table :fingerprint_device_access_logs do |t|
      t.references :fingerprint_device
      t.datetime :access_time
      t.string :description
      t.boolean :status
    end
  end

  def self.down
    drop_table :fingerprint_device_access_logs
  end
end
