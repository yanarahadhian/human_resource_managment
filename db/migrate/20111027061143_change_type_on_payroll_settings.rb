class ChangeTypeOnPayrollSettings < ActiveRecord::Migration
  def self.up
  	change_column :payroll_settings, :full_working_days, :integer 	
  end

  def self.down
  	change_column :payroll_settings, :full_working_days, :string
  end
end