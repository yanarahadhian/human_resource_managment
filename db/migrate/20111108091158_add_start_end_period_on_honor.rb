class AddStartEndPeriodOnHonor < ActiveRecord::Migration
  def self.up
  	add_column :honors, :start_period, :date
  	add_column :honors, :end_period, :date
  end

  def self.down
  	remove_column :honors, :start_period
  	remove_column :honors, :end_period
  end
end