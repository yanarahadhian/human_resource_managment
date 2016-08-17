class RemovePtkpFromPayrollSetting < ActiveRecord::Migration
  def self.up
     remove_column :payroll_settings, :ptkp
  end

  def self.down
  end
end
