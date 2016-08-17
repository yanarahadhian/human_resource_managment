class AddDefaultValueOnHrSetting < ActiveRecord::Migration
  def self.up
  	change_table :hr_settings do |t|
  	  t.change :is_company_overtime, :boolean, :default => false
  	end
  end

  def self.down
  	change_table :hr_settings do |t|
  	  t.change :is_company_overtime, :boolean, :default => NULL
  	end
  end
end