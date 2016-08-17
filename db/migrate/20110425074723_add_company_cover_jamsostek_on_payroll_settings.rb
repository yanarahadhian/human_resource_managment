class AddCompanyCoverJamsostekOnPayrollSettings < ActiveRecord::Migration
  def self.up
  	add_column :payroll_settings, :company_cover_jamsostek, :decimal, :precision => 12, :scale => 2
  end

  def self.down
  	remove_column :payroll_settings, :company_cover_jamsostek
  end
end