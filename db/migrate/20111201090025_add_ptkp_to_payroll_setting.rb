class AddPtkpToPayrollSetting < ActiveRecord::Migration
  def self.up
    add_column :payroll_settings, :ptkp, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    remove_column :payroll_settings, :ptkp
  end
end
