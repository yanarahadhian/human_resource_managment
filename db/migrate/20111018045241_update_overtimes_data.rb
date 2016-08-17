class UpdateOvertimesData < ActiveRecord::Migration
  def self.up
    company_ids = Person.all.map(&:company_id).uniq
    company_ids.each do |company_id|
      people = Person.all(:conditions => ['company_id = ?', company_id])
      update_report = []
      people.each do |person|
        overtimes = person.overtimes.find(:all, :conditions => ['overtime_description = "Lembur Wajib"'], :order => :overtime_date)
        overtime_dates = overtimes.map(&:overtime_date).uniq
        overtime_dates.each do |overtime_date|
          overtime_on_date = overtimes.find_all{|x| x.overtime_date == overtime_date}
          if overtime_on_date.length > 0
            overtime_on_date.each do |o|
              o.destroy if o.overtime_length_in_minutes == 0
              o.destroy unless o == overtime_on_date.last
            end
            person_overtime = person.overtimes.sum(:overtime_length_in_minutes, :conditions => ['overtime_date = ? AND overtime_status = ?', overtime_date, "Approved"])
            update_report.push "UPDATE presence_reports SET  `overtime_duration` = #{person_overtime/60.0} WHERE `person_id` = #{person.id} AND `date` = '#{overtime_date.to_s(:db)}'"
          end
        end
      end unless people.blank?
      unless update_report.blank?
        PresenceReport.transaction do
          update_report.each do |update|
            PresenceReport.connection.execute update
          end
        end
      end
    end
  end

  def self.down
  end
end
