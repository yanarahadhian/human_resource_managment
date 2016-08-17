class AddCompanyIdToFingerprintDevices < ActiveRecord::Migration
  def self.up
    add_column :fingerprint_devices, :company_id, :integer
    add_index :people, :fingerprint_user
  end

  def self.down
    remove_column :fingerprint_devices, :company_id
    remove_index :people, :fingerprint_user
  end
end

