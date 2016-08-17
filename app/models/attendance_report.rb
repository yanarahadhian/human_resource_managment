class AttendanceReport < ActiveRecord::Base
  belongs_to :person

#  def self.insert_attendance_report(start_date, end_date, company_id)
#    conditions = Person.without_keluar_masuk + " AND people.company_id=#{company_id}"
#    people = Person.all(:conditions => conditions)
#
#    unless people.blank?
#      people.each do |person|
#        late_counter = PresenceReport.calculate_delay_working_time(person, start_date, end_date)
#        @attendance_report = self.new
#        @attendance_report.person_id = person.id
#        @attendance_report.company_id = company_id
#        @attendance_report.start_date = start_date
#        @attendance_report.end_date = end_date
#        @attendance_report.late_before_and_at_15_minutes_count = late_counter[:late_before_and_at_15_minutes_count]
#        @attendance_report.late_after_15_minutes_count = late_counter[:late_after_15_minutes_count]
#        @attendance_report.absences_count = person.employee_leaves.all(:conditions => ["leave_date between ? AND ?", start_date, end_date]).count
#        @attendance_report.save
#      end
#    end
#  end

  def self.current_report_for(person_id, company_id, start_date, end_date)
    attendance_report = AttendanceReport.find(:first, :conditions =>
      ["person_id = ? and company_id = ? and start_date = ? and end_date = ?",
      person_id, company_id, start_date, end_date])
    attendance_report
  end

  def self.insert_report_for(person_id, company_id, start_date, end_date, summary)
    attendance_report = self.new
    attendance_report.person_id = person_id
    attendance_report.company_id = company_id
    attendance_report.start_date = start_date
    attendance_report.end_date = end_date
    attendance_report.late_before_and_at_15_minutes_count = summary[:late_before_and_at_15_minutes_count]
    attendance_report.late_after_15_minutes_count = summary[:late_after_15_minutes_count]
    attendance_report.absences_count = Person.find(person_id).employee_leaves.all(:conditions => ["leave_date between ? AND ?", start_date, end_date]).count
    attendance_report.save
  end

end


