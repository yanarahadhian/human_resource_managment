class AddAbsenceTypeIdToPresenceReports < ActiveRecord::Migration
  def self.up
    add_column :presence_reports, :absence_type_id, :integer
    add_index :presence_reports, :absence_type_id
    add_index :presence_reports, :shift_code
    PresenceReport.reset_column_information

    PresenceReport.destroy_raw_data
    PresenceReport.insert_presence_report
  end

  def self.down
    remove_index :presence_reports, :shift_code
    remove_index :presence_reports, :absence_type_id
    remove_column :presence_reports, :absence_type_id
  end
end
