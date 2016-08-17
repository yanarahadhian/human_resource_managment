class RenameChangeTypeInShiftForBreakInPercentage < ActiveRecord::Migration
  def self.up
    change_column :work_times, :break_length_in_percentage, :integer
    rename_column :work_times, :break_length_in_percentage, :break_per_hour_in_minutes
  end

  def self.down
    change_column :work_times, :break_per_hour_in_minutes, :float
    rename_column :work_times, :break_per_hour_in_minutes, :break_length_in_percentage
  end
end
