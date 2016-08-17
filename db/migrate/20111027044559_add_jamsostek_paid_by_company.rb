class AddJamsostekPaidByCompany < ActiveRecord::Migration
  def self.up
    add_column :payroll_settings,:jamsostek_paid_by_company, :boolean, :default => false
  end

  def self.down
    remove_column :payroll_settings,:jamsostek_paid_by_company
  end
end
