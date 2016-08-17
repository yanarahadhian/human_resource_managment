class AddCutOffDateOnPayrollSettings < ActiveRecord::Migration
  def self.up
  	add_column :payroll_settings, :cut_off_date, :integer
  end

  def self.down
  	remove_column :payroll_settings, :cut_off_date
  end
end