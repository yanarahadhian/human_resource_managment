class AddIsDailyEmployeesAndIsPermanentEmployeesToWorkConctract < ActiveRecord::Migration
  def self.up
    add_column :work_contracts, :is_daily_employee, :boolean, :default => false
    add_column :work_contracts, :is_permanent_employee, :boolean, :default => false
  end

  def self.down
    remove_column :work_contracts, :is_daily_employee
    remove_column :work_contracts, :is_permanent_employee
  end
end
