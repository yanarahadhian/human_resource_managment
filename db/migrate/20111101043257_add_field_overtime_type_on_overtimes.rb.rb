class AddFieldOvertimeTypeOnOvertimes < ActiveRecord::Migration
  def self.up
    add_column :overtimes, :overtime_type, :string
    add_column :presence_reports, :special_overtime, :float

    Overtime.reset_column_information
    PresenceReport.reset_column_information
    overtimes = Overtime.all
    overtime_people_id = overtimes.map(&:person_id).uniq
    overtime_people = Person.all(:conditions =>{:id => overtime_people_id} )
    overtimes.each do |overtime|
      if overtime.overtime_description == "Lembur Wajib"
        overtime.overtime_type = overtime.overtime_description
        overtime.overtime_description = nil
        overtime.save!
      end
    end
    updates = []
    overtime_people.each do |person|
      person_overtime_dates = person.overtimes.map(&:overtime_date).uniq
      person_overtime_dates.each do |odate|
        overtime_duration = person.overtimes.sum(:overtime_length_in_minutes, :conditions => ['overtime_date = ? AND overtime_status = ?', odate, "Approved"])
        special_overtime = person.overtimes.sum(:overtime_length_in_minutes, :conditions => ['overtime_date = ? AND overtime_status = ? AND overtime_type = ?', odate, "Approved", "Lembur Khusus"])
        if special_overtime > 0
          updates.push "UPDATE presence_reports SET  `special_overtime` = #{special_overtime/60.0}, `overtime_duration` = #{(overtime_duration - special_overtime)/60.0} WHERE `person_id` = #{person.id} AND `date` = '#{odate.to_s(:db)}'"
        end
      end
    end
    unless updates.blank?
      PresenceReport.transaction do
        updates.each do |update|
          PresenceReport.connection.execute update
        end
      end
    end
  end

  def self.down
    remove_column :overtimes, :overtime_type
    remove_column :presence_reports, :special_overtime
  end
end
