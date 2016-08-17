class AddLastDownloadToFingerprintDevice < ActiveRecord::Migration
  def self.up
    remove_column :people, :fingerprint_device_id
    add_column :fingerprint_devices, :last_download, :datetime
  end

  def self.down
    add_column :people, :fingerprint_device_id, :integer
    remove_column :fingerprint_devices, :last_download
  end
end

