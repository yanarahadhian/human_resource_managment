class ChangeAndAddColumnOnNationalHoliday < ActiveRecord::Migration
  def self.up
    rename_column(:national_holidays, :holiday_date, :holiday_start_date)
    add_column :national_holidays, :holiday_end_date, :date
    NationalHoliday.reset_column_information
    NationalHoliday.find(:all).each do |p|
      p.update_attribute :holiday_end_date, p.holiday_start_date + (p.holiday_duration - 1).days
    end
  end

  def self.down
    rename_column(:national_holidays, :holiday_start_date, :holiday_date)
    remove_column :national_holidays, :holiday_end_date
  end
end
