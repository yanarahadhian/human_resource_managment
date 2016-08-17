class ChangeTypeDataOnWorkTimes < ActiveRecord::Migration
  def self.up
    change_column :work_times, :start_time, :time
    change_column :work_times, :end_time, :time
  end

  def self.down
    change_column :work_times, :start_time, :datetime
    change_column :work_times, :end_time, :datetime
  end
end

