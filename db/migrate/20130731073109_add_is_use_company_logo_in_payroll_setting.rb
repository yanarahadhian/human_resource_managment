class AddIsUseCompanyLogoInPayrollSetting < ActiveRecord::Migration
  def self.up
  	add_column :payroll_settings, :use_logo_in_payroll_slip, :boolean, :default => false
  end

  def self.down
  	remove_column :payroll_settings, :use_logo_in_payroll_slip
  end
end
