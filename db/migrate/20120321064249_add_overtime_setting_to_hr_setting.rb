class AddOvertimeSettingToHrSetting < ActiveRecord::Migration
  def self.up
    add_column :hr_settings, :is_company_overtime, :boolean
  end

  def self.down
    remove_column :hr_settings, :is_company_overtime
  end
end