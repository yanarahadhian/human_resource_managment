class AddPeoplePayJamsotekToPayrollSetting < ActiveRecord::Migration
  def self.up
    add_column :payroll_settings, :jamsostek_value, :decimal
  end

  def self.down
    remove_column :payroll_settings, :jamsostek_value
  end
end
