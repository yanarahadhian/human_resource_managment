# == Schema Information
#
# Table name: work_times
#
#  id                             :integer(4)      not null, primary key
#  company_id                     :integer(4)
#  start_time                     :time
#  end_time                       :time
#  length_in_hours                :decimal(8, 4)
#  break_length_in_minutes        :integer(4)
#  break_per_hour_in_minutes      :integer(4)
#  compulsory_overtime_in_minutes :integer(4)
#  created_at                     :datetime
#  updated_at                     :datetime
#

class WorkTime < ActiveRecord::Base
  has_one :shift
  validates_presence_of :break_length_in_minutes
  validates_presence_of :break_per_hour_in_minutes
  attr_protected :company_id

  def self.check_data(current_company_id,work_time)
    check = self.find(:first,:conditions => ["company_id = ?",current_company_id])
    if check.blank?
      puts "    6. Running Work Times"
      # work = work_time.to_a.rand
      time_shift = Array.new
      work_time.to_a.each do |work|
        total_hour = 0
        (1..7).each do |d|
          start = (work[1]["offday"] == d) ? "00:00:00" : work[1]["start"]
          end_time = (work[1]["offday"] == d ) ? "00:00:00" : work[1]["end"]
          hours = (work[1]["offday"] == d ) ? "0" : work[1]["hours"]
          breaks =  (work[1]["offday"] == d ) ? "0" : work[1]["break"]
          overtime = (work[1]["offday"] == d) ? "0" : work[1]["overtime"]
          # time_cal = Shift.calculate_length_in_hours(start, end_time,breaks,"per_day")
          data = self.new()
          data.company_id = current_company_id
          data.start_time = start
          data.end_time   = end_time
          data.length_in_hours = hours
          data.break_length_in_minutes = breaks
          data.break_per_hour_in_minutes = breaks
          data.compulsory_overtime_in_minutes = overtime
          total_hour = total_hour + hours.to_i
          if data.save
            time_shift << data.id
          end
        end
        unless time_shift.blank?
          shift = Shift.new()
          shift.company_id = current_company_id
          shift.shift_name = work[0]
          shift.shift_category = "Shift"
          shift.total_hours = total_hour
          shift.shift_code = work[1]["kode"]
          shift.break_choice = "per_day"
          shift.working_hour_per_week = work[1]["hour_perweek"]
          shift.monday_time_id = time_shift[0]
          shift.tuesday_time_id = time_shift[1]
          shift.wednesday_time_id = time_shift[2]
          shift.thursday_time_id = time_shift[3]
          shift.friday_time_id = time_shift[4]
          shift.saturday_time_id = time_shift[5]
          shift.sunday_time_id = time_shift[6]
          shift.save!
        end
      end
    end
  end

end


