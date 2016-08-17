class AddWorkingHourPerWeekToShifts < ActiveRecord::Migration
  def self.up
    add_column :shifts, :working_hour_per_week, :integer, :default => 40
  end

  def self.down
    remove_column :shifts, :working_hour_per_week
  end
end
