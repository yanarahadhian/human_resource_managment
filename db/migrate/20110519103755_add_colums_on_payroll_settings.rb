class AddColumsOnPayrollSettings < ActiveRecord::Migration
  def self.up
    add_column :payroll_settings, :payroll_by_bca, :boolean
  end

  def self.down
    remove_column :payroll_settings, :payroll_by_bca
  end
end