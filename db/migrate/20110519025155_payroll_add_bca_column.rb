class PayrollAddBcaColumn < ActiveRecord::Migration
  def self.up
    add_column :payroll_settings, :bca_branch_code, :string
    add_column :payroll_settings, :bca_company_code, :string
    add_column :payroll_settings, :bca_company_initial, :string
    add_column :payroll_settings, :bca_company_account_number, :string
  end

  def self.down
    remove_column :payroll_settings, :bca_branch_code
    remove_column :payroll_settings, :bca_company_code
    remove_column :payroll_settings, :bca_company_initial
    remove_column :payroll_settings, :bca_company_account_number
  end
end
