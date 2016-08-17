class AddColumnHoliday < ActiveRecord::Migration
  def self.up
    add_column :national_holidays, :holiday_duration, :int
    add_column :national_holidays, :leave_duration, :int
  end

  def self.down
    remove_column :national_holidays, :holiday_duration
    remove_column :national_holidays, :leave_duration
  end
end
