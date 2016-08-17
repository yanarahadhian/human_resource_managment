class AddShiftCodeToShiftsAndReports < ActiveRecord::Migration
  def self.up
    add_column :presence_reports, :shift_code, :string, :limit => 10
    add_column :shifts, :shift_code, :string, :limit => 10
    PresenceReport.reset_column_information
    Shift.reset_column_information
    Shift.find(:all).each do |s|
      s.update_attribute :shift_code, s.shift_name.upcase.scan(/\b\w/)*''
    end

    PresenceReport.destroy_raw_data
    PresenceReport.insert_presence_report
  end

  def self.down
    remove_column :presence_reports, :shift_code
    remove_column :shifts, :shift_code
  end
end
