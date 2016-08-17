class ChangeBreakInPercentageInWorkTimesToDecimal < ActiveRecord::Migration
  def self.up
     change_column :work_times, :break_length_in_percentage, :float
  end

  def self.down
    change_column :work_times, :break_length_in_percentage, :integer
  end
end
