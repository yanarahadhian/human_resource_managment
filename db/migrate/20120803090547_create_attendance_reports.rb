class CreateAttendanceReports < ActiveRecord::Migration
  def self.up
    create_table :attendance_reports do |t|
      t.references  :person
      t.integer     :company_id
      t.string      :start_date
      t.string      :end_date
      t.integer     :presences_count
      t.integer     :late_before_and_at_15_minutes_count
      t.integer     :late_after_15_minutes_count
      t.integer     :absences_count
      t.integer     :absences_cut_employee_leave_quota
      t.timestamps
    end
    add_index :attendance_reports, :id
  end

  def self.down
    drop_table :attendance_reports
  end
end
