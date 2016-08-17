class AddSomeNotificationFlag < ActiveRecord::Migration
 def self.up
    add_column :hr_settings, :employee_is_set, :boolean, :default => false
    add_column :hr_settings, :hr_setting_is_set, :boolean, :default => false
    add_column :hr_settings, :holidays_is_set, :boolean, :default => false
    add_column :hr_settings, :absence_types_is_set, :boolean, :default => false 
    add_column :hr_settings, :shift_is_set, :boolean, :default => false
    add_column :hr_settings, :organization_structure_is_set, :boolean, :default => false
    add_column :hr_settings, :schedule_is_set, :boolean, :default => false
    add_column :hr_settings, :no_schedule, :integer, :default => 0
    add_column :hr_settings, :payroll_setting_is_set, :boolean, :default => false
    add_column :hr_settings, :fingerprint_device_is_set, :boolean, :default => false
    add_column :hr_settings, :fingerprint_device_is_connected, :boolean, :default => false
  end

  def self.down
    remove_column :hr_settings, :employee_is_set
    remove_column :hr_settings, :hr_setting_is_set
    remove_column :hr_settings, :holidays_is_set
    remove_column :hr_settings, :absence_types_is_set 
    remove_column :hr_settings, :shift_is_set
    remove_column :hr_settings, :organization_structure_is_set
    remove_column :hr_settings, :schedule_is_set
    remove_column :hr_settings, :no_schedule, :integer, :default => 0
    remove_column :hr_settings, :payroll_setting_is_set
    remove_column :hr_settings, :fingerprint_device_is_set
    remove_column :hr_settings, :fingerprint_device_is_connected
  end
end