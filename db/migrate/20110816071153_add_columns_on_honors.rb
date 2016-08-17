class AddColumnsOnHonors < ActiveRecord::Migration
  def self.up
  	add_column :honors, :rounding_off, :decimal, :precision => 12, :scale => 2
  	add_column :honors, :rounding_off_month_net_income, :decimal, :precision => 12, :scale => 2
  	add_column :honors, :total_final_take_home_pay, :decimal, :precision => 12, :scale => 2
  end

  def self.down
  	remove_column :honors, :rounding_off
  	remove_column :honors, :rounding_off_month_net_income
  	remove_column :honors, :total_final_take_home_pay
  end
end