class ChangeTypeTotalHoursOnShifts < ActiveRecord::Migration
  def self.up
    change_column :shifts, :total_hours, :float
    Shift.reset_column_information
    shifts = Shift.all
    shifts.each do |shift|
      total = shift.monday_time.length_in_hours.to_f
      total += shift.tuesday_time.length_in_hours.to_f
      total += shift.wednesday_time.length_in_hours.to_f
      total += shift.thursday_time.length_in_hours.to_f
      total += shift.friday_time.length_in_hours.to_f
      total += shift.saturday_time.length_in_hours.to_f
      total += shift.sunday_time.length_in_hours.to_f
      shift.update_attributes(:total_hours => total)
    end
  end

  def self.down
    change_column :shifts, :total_hours, :integer
  end
end
