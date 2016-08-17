class AddColumsOnPresenceReports < ActiveRecord::Migration
  def self.up
  	add_column :presence_reports, :total_overtime_this_week, :float
  	add_column :presence_reports, :unaccounted_noncompulsory_overtime, :float
  	add_index :presence_reports, :total_overtime_this_week
  	add_index :presence_reports, :unaccounted_noncompulsory_overtime
  end

  def self.down
  	remove_index :presence_reports, :total_overtime_this_week
  	remove_index :presence_reports, :unaccounted_noncompulsory_overtime
  	remove_column :presence_reports, :total_overtime_this_week
  	remove_column :presence_reports, :unaccounted_noncompulsory_overtime
  end
end