class PresenceReport < ActiveRecord::Base

  def self.find_by_custom_conditions(current_conditions)
    rv = []
    presences = find(:all, :conditions => current_conditions, :order => :date)
    
    presences.each do |presence|
      if rv.blank?
        rv << presence
      else
        rv << presence if rv.last and rv.last.date != presence.date
      end
    end
    rv
  end

  def self.summary_report(start_date, end_date, company_id, options = {})
    presence_reports = PresenceReport.report_by_date_range(start_date, end_date, company_id, options)
    people_id = presence_reports.map(&:person_id).uniq
    limit = options[:display_length]
    offset = options[:start_index]
    unless limit.blank?
      people = Person.all(:conditions => ["id in (?) AND latest_employment_id is not null", people_id], :limit => limit, :offset => offset)
    else
      people = Person.all(:conditions => ["id in (?) AND latest_employment_id is not null", people_id])
    end
    summaries = []
    unless people.blank?
      people.each do |person|
        person_presence_reports = presence_reports.find_all{|x| x.person_id == person.id}
        summary = {:name => person_presence_reports.first.full_name,
          :department => person_presence_reports.first.department_name,
          :division => person_presence_reports.first.division_name,
          :work_time => [], :shift_code => [], :date => [], :weekly_overtime => [],
          :overtime1 => 0.0, :overtime2 => 0.0, :overtime3 => 0.0,
          :overtime4 => 0.0, :overtime_total => 0.0,
          :employee_id => person.employee_identification_number,
          :person_id => person.id
        }
        overtime1 = 0.0
        overtime2 = 0.0
        overtime3 = 0.0
        overtime4 = 0.0
        holiday_hour = 0.0
        compulsory_overtime = 0.0
        wo1 = 0.0
        wo2 = 0.0
        wo3 = 0.0
        wo4 = 0.0
        (start_date..end_date).each do |date|
          report = person_presence_reports.find{|pp| pp.date == date}
          summary[:date] << date
          summary[:weekly_overtime] << 0
          unless report.blank?
            summary[:shift_code] << if report.shift_code.include?("N/A") then "-" else report.shift_code end
            if report.presence_id
              summary[:work_time] << report.work_duration
            else
              summary[:work_time] << report.absence_code
            end
            unless report.is_holiday
              compulsory_overtime = report.overtime_duration.to_f
              if report.overtime_duration.to_f > 1
                overtime1 += 1
                overtime2 += report.overtime_duration - 1
                wo1 += 1
                wo2 += report.overtime_duration - 1
              else
                overtime1 += report.overtime_duration.to_f
                wo1 += report.overtime_duration.to_f
              end
            else
              holiday_hour += report.overtime_duration.to_f
            end
            overtime2 += report.special_overtime.to_f
            wo2 += report.special_overtime.to_f
            if report.date.wday == 0 || report.date == end_date
              if report.unaccounted_noncompulsory_overtime.to_f > 0
                if compulsory_overtime > 1
                  overtime2 += report.unaccounted_noncompulsory_overtime.to_f
                  wo2 += report.unaccounted_noncompulsory_overtime.to_f
                else
                  overtime1 += (1 - compulsory_overtime)
                  overtime2 += report.unaccounted_noncompulsory_overtime.to_f - (1 - compulsory_overtime)
                  wo1 += (1 - compulsory_overtime)
                  wo2 += report.unaccounted_noncompulsory_overtime.to_f - (1 - compulsory_overtime)
                end
              end
              if holiday_hour >= 8
                overtime4 += holiday_hour - 8
                overtime3 += 1
                overtime2 += 7
                wo4 += holiday_hour - 8
                wo3 += 1
                wo2 += 7
              elsif holiday_hour >= 7
                overtime3 += holiday_hour - 7
                overtime2 += 7
                wo3 += holiday_hour - 7
                wo2 += 7
              else
                overtime2 += holiday_hour
                wo2 += holiday_hour
              end
              summary[:weekly_overtime][-1] = wo1 * 1.5 + wo2 * 2 + wo3 * 3 + wo4 * 4
              wo1 = 0.0
              wo2 = 0.0
              wo3 = 0.0
              wo4 = 0.0
              holiday_hour = 0.0
              compulsory_overtime = 0.0
            end
          else
            shift = person.current_shift(date)
            shift_code = shift.blank? ? "-" : shift.shift_code
            summary[:shift_code] << shift_code
            summary[:work_time] << "-"
          end
        end
        summary[:overtime1] = overtime1
        summary[:overtime2] = overtime2
        summary[:overtime3] = overtime3
        summary[:overtime4] = overtime4
        summary[:overtime_total] = overtime1 * 1.5 + overtime2 * 2 + overtime3 * 3 + overtime4 * 4
        summaries << summary
      end
    end
    return summaries
  end

  def self.summary_absence_report(start_date, end_date, conditions, people, options = {})
    summaries = []
    unless people.blank?
      people.each do |person|
        attendance_report = AttendanceReport.current_report_for(person.id, person.company_id, start_date, end_date)
        
        if attendance_report.blank?
          late_counter = PresenceReport.calculate_delay_working_time(person, start_date, end_date)
          summary = {:employee_reg_id => person.employee_identification_number,
            :name => person.full_name,
            :employee_id => person.id,
            :total_absence => person.employee_leaves.all(:conditions => ["leave_date between ? AND ?", start_date, end_date]).count,
            :late_before_and_at_15_minutes_count => late_counter[:late_before_and_at_15_minutes_count],
            :late_after_15_minutes_count => late_counter[:late_after_15_minutes_count]
          }
          #AttendanceReport.insert_report_for(person.id, person.company_id, start_date, end_date, summary)
          summaries << summary
        else
          summary = {:employee_id => person.employee_identification_number,
            :name => person.full_name,
            :total_absence => attendance_report.absences_count,
            :late_before_and_at_15_minutes_count => attendance_report.late_before_and_at_15_minutes_count,
            :late_after_15_minutes_count => attendance_report.late_after_15_minutes_count
          }
          summaries << summary
        end
      end
    end
    return summaries
  end

  def self.calculate_delay_working_time(person, start_date, end_date)
    presences = person.presences.all(:conditions => ["presence_date between ? AND ?", start_date, end_date])
    late_before_and_at_15_minutes_count = 0
    late_after_15_minutes_count = 0
    unless presences.blank?
      presences.each do |p|
        working_time = p.presence_details.first.start_working
        unless person.employee_shifts.blank?
          shift = person.employee_shifts.last.shift
          unless working_time.blank?
            working_shift = shift.daily_schedule(working_time).start_time

            working_time_in_second = (working_time.hour + 7 ).to_f * 3600 + working_time.min.to_f * 60 + working_time.sec.to_f
            working_shift_in_second = working_shift.hour.to_f * 3600 + working_shift.min.to_f * 60 + working_shift.sec.to_f
            time_late = working_time_in_second - working_shift_in_second

            if time_late > 900
              late_after_15_minutes_count += 1
            elsif time_late > 0 && time_late < 900
              late_before_and_at_15_minutes_count += 1
            end
          end
        end
      end
    
    end
    counter = {:late_before_and_at_15_minutes_count => late_before_and_at_15_minutes_count,
      :late_after_15_minutes_count => late_after_15_minutes_count
    }
    return counter
  end

  def self.count_total_by_date_range(start_date, end_date, company_id, options = {})
    presence_reports = PresenceReport.report_by_date_range(start_date, end_date, company_id, options)
    people_id = presence_reports.map(&:person_id).uniq
    people_count = Person.count(:conditions => ["id in (?) AND latest_employment_id is not null", people_id])
    return people_count
  end

  def self.report_by_date_range(start_date, end_date, company_id, options = {})
    kond = "company_id = #{company_id} AND date BETWEEN '#{start_date.to_s(:db)}' AND '#{end_date.to_s(:db)}'"
    unless options.blank?
      person_id = find_person_id(options)
      unless person_id.blank?
        kond << " AND person_id in (#{person_id.join(",")})"
      end
      if options[:department_id]
        kond << " AND department_id = #{options[:department_id]}"
      end
      if options[:division_id]
        kond << " AND division_id = #{options[:division_id]}"
      end
    end
    presence_reports = PresenceReport.find(:all, :conditions => kond)
    return presence_reports
  end

  def self.find_person_id(options)
    kond = ""
    if options[:name]
      kond << "CONCAT(TRIM(people.firstname),' ',TRIM(people.lastname)) like '%#{options[:name]}%'"
    end
    if options[:nik]
      kond = " AND " unless kond.blank?
      kond << "employee_id LIKE '%#{options[:nik]}%'"
    end
    if options[:contract_type].to_i > 0
      work_contracts = WorkContract.all(:select => "id", :conditions => ["contract_type_id = ?",options[:contract_type]]).collect(&:id)
      unless work_contracts.blank?
        kond = " AND " unless kond.blank?
        kond << "latest_work_contract_id in (#{work_contracts.join(",")})"
      end
    end
    person = Person.find(:all, :select=> "id",:conditions => kond)
    unless person.blank?
      return person.collect{ |x| x.id}.uniq.compact
    else
      return nil
    end
  end

  def self.search_for_dashboard(options = {})
    unless options.blank?
      if !options[:division_id].blank?
        return find(:all, :conditions => ['division_id = ? AND date BETWEEN ? AND ?', options[:division_id], options[:start_date], options[:end_date]])
      elsif !options[:department_id].blank?
        return find(:all, :conditions => ['department_id = ? AND date BETWEEN ? AND ?', options[:department_id], options[:start_date], options[:end_date]])
      else
        presece_report = find(:all, :conditions => ['company_id = ? AND date BETWEEN ? AND ?', options[:company_id], options[:start_date], options[:end_date]])
        return presece_report
      end
    end
  end

  def self.insert_presence_report
    logfile = File.open("#{RAILS_ROOT}/log/scheduler.log", 'a')
    logfile.sync = true
    scheduler_log = Logger.new(logfile)
    scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Insert Presence Report started"
    company_ids = User.all.map(&:company_id).uniq
    result = []
    unless company_ids.blank?
      company_ids.each do |company_id|
        presence_report = PresenceReport.last(:conditions => ['company_id = ?', company_id], :order => :updated_at)
        start_date = nil
        scheduler_log.debug "-- #{Time.now.strftime("%F %H:%M:%S")} - Starting Insert or Update Presence Reports"
        people = Person.all(:conditions => ['company_id = ?', company_id])
        end_date = Date.today
        inserted = 0
        unless people.blank?
          inserts = []
          people.each do |person|
            unless presence_report.blank?
              presences = person.presences.all(:conditions => ['updated_at > ?', presence_report.updated_at], :order => :presence_date)
              absences = person.absences.all(:conditions => ['updated_at > ?', presence_report.updated_at], :order => :absence_date)
            else
              presences = person.presences.all(:order => :presence_date)
              absences = person.absences.all(:conditions => ['absence_date <= ?', Date.today], :order => :absence_date)
            end
            unless presences.blank?
              start_date = presences.first.presence_date
            end
            if start_date.blank?
              start_date = absences.first.absence_date unless absences.blank?
              start_date = Date.today if start_date.blank?
            end
            unless presences.blank?
              presences.each do |presence|
                shift = person.current_shift(presence.presence_date)
                shift_code = shift.blank? ? "-" : shift.shift_code
                department = person.department(presence.presence_date)
                division = person.division(presence.presence_date)
                non_workday = person.current_schedule(presence.presence_date).blank?
                is_holiday = NationalHoliday.is_holiday?(company_id, presence.presence_date) || non_workday
                overtime_in_minutes = person.overtimes.sum(:overtime_length_in_minutes, :conditions => ['overtime_date = ? AND overtime_status = ?', presence.presence_date, "Approved"])
                special_overtime = person.overtimes.sum(:overtime_length_in_minutes, :conditions => ['overtime_date = ? AND overtime_status = ? AND overtime_type LIKE ?', presence.presence_date, "Approved", "%Lembur Khusus%"])
                work_length = presence.net_worktime.to_f
                inserts.push "#{presence.id},null,#{person.company_id},#{department.blank? ? "null":department.id},#{division.blank? ? "null":division.id},#{person.id},'#{person.employee_identification_number.to_s}','#{presence.presence_date.to_s(:db)}',#{is_holiday},\"#{person.full_name}\",'#{department.department_name if department}','#{division.name if division}',null,#{work_length},#{(overtime_in_minutes.to_f - special_overtime.to_f)/60.0},'#{presence.updated_at.utc.to_s(:db)}','#{shift_code}', null, #{special_overtime.to_f/60.0}"
              end
            end
            unless absences.blank?
              absences.each do |absence|
                shift = person.current_shift(absence.absence_date)
                shift_code = shift.blank? ? "-" : shift.shift_code
                department = person.department(absence.absence_date)
                division = person.division(absence.absence_date)
                absence_type = absence.absence_type
                absence_type_code = absence_type.absence_type_code
                absence_type_id = absence_type.type_id
                non_workday = person.current_schedule(absence.absence_date).blank?
                is_holiday = NationalHoliday.is_holiday?(company_id, absence.absence_date) || non_workday
                inserts.push "null,#{absence.id},#{person.company_id},#{department.blank? ? "null":department.id},#{division.blank? ? "null":division.id},#{person.id},'#{person.employee_identification_number.to_s}','#{absence.absence_date.to_s(:db)}',#{is_holiday},\"#{person.full_name}\",'#{department.department_name if department}','#{division.name if division}','#{absence_type_code}',null,null,'#{absence.updated_at.utc.to_s(:db)}','#{shift_code}',#{absence_type_id.blank? ? "null": absence_type_id}, null"
              end
            end
            unless inserts.blank?
              PresenceReport.transaction do
                inserts.each do |insert|
                  sql = "REPLACE INTO presence_reports (`presence_id`, `absence_id`, `company_id`, `department_id`, `division_id`, `person_id`, `employee_id`, `date`, `is_holiday`, `full_name`, `department_name`, `division_name`, `absence_code`, `work_duration`, `overtime_duration`,`updated_at`,`shift_code`,`absence_type_id`,`special_overtime`) VALUES (#{insert})"
                  PresenceReport.connection.execute sql
                end
              end
              inserted += inserts.length
              inserts = []
            end
            presence_dates = presences.map(&:presence_date)
            absence_dates = absences.map(&:absence_date)
            free_dates = (start_date..end_date).to_a - (absence_dates + presence_dates).uniq
            free_dates.each do |date|
              presence_report = PresenceReport.first(:conditions => ['person_id = ? AND date = ?',person.id, date])
              employment = person.employment(date)
              if !employment.blank? && presence_report.blank?
                shift = person.current_shift(date)
                shift_code = shift.blank? ? "-" : shift.shift_code
                department = person.department(date)
                division = person.division(date)
                non_workday = person.current_schedule(date).blank?
                is_holiday = NationalHoliday.is_holiday?(company_id, date) || non_workday
                absence_code = "-"
                if is_holiday
                  absence_code = "L"
                end
                inserts.push "null,null,#{person.company_id},#{department.blank? ? "null":department.id},#{division.blank? ? "null":division.id},#{person.id},'#{person.employee_identification_number.to_s}','#{date.to_s(:db)}',#{is_holiday},\"#{person.full_name}\",'#{department.department_name if department}','#{division.name if division}','#{absence_code}',null,null,'#{Time.now.utc.to_s(:db)}','#{shift_code}',null,null"
              end
            end
            unless inserts.blank?
              PresenceReport.transaction do
                inserts.each do |insert|
                  sql = "REPLACE INTO presence_reports (`presence_id`, `absence_id`, `company_id`, `department_id`, `division_id`, `person_id`, `employee_id`, `date`, `is_holiday`, `full_name`, `department_name`, `division_name`, `absence_code`, `work_duration`, `overtime_duration`,`updated_at`,`shift_code`,`absence_type_id`,`special_overtime`) VALUES (#{insert})"
                  PresenceReport.connection.execute sql
                end
              end
              inserted += inserts.length
            end
          end
          scheduler_log.debug "-- #{Time.now.strftime("%F %H:%M:%S")} - #{inserted} Records Inserted or Updated to Presence Reports on Company #{company_id}"
          result << {:company => company_id, :status => true}
        else
          scheduler_log.debug "-- #{Time.now.strftime("%F %H:%M:%S")} - No data affected on Company #{company_id}"
          result << {:company => company_id, :status => false}
        end
      end
    end
    scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Insert Presence Report Ended"
    return result
  end

  def self.insert_presence_report_by_company_id(company_id)
    logfile = File.open("#{RAILS_ROOT}/log/scheduler.log", 'a')
    logfile.sync = true
    scheduler_log = Logger.new(logfile)
    scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Insert Presence Report started"
    result = []
    unless company_id.blank?
      presence_report = PresenceReport.last(:conditions => ['company_id = ?', company_id], :order => :updated_at)
      start_date = nil
      scheduler_log.debug "-- #{Time.now.strftime("%F %H:%M:%S")} - Starting Insert or Update Presence Reports"
      people = Person.all(:conditions => ['company_id = ?', company_id])
      end_date = Date.today
      inserted = 0
      unless people.blank?
        inserts = []
        people.each do |person|
          unless presence_report.blank?
            presences = person.presences.all(:conditions => ['updated_at > ?', presence_report.updated_at], :order => :presence_date)
            absences = person.absences.all(:conditions => ['updated_at > ?', presence_report.updated_at], :order => :absence_date)
          else
            presences = person.presences.all(:order => :presence_date)
            absences = person.absences.all(:conditions => ['absence_date <= ?', Date.today], :order => :absence_date)
          end
          unless presences.blank?
            start_date = presences.first.presence_date
          end
          if start_date.blank?
            start_date = absences.first.absence_date unless absences.blank?
            start_date = Date.today if start_date.blank?
          end
          unless presences.blank?
            presences.each do |presence|
              shift = person.current_shift(presence.presence_date)
              shift_code = shift.blank? ? "-" : shift.shift_code
              department = person.department(presence.presence_date)
              division = person.division(presence.presence_date)
              non_workday = person.current_schedule(presence.presence_date).blank?
              is_holiday = NationalHoliday.is_holiday?(company_id, presence.presence_date) || non_workday
              overtime_in_minutes = person.overtimes.sum(:overtime_length_in_minutes, :conditions => ['overtime_date = ? AND overtime_status = ?', presence.presence_date, "Approved"])
              special_overtime = person.overtimes.sum(:overtime_length_in_minutes, :conditions => ['overtime_date = ? AND overtime_status = ? AND overtime_type LIKE ?', presence.presence_date, "Approved", "%Lembur Khusus%"])
              work_length = presence.net_worktime.to_f
              inserts.push "#{presence.id},null,#{person.company_id},#{department.blank? ? "null":department.id},#{division.blank? ? "null":division.id},#{person.id},'#{person.employee_identification_number.to_s}','#{presence.presence_date.to_s(:db)}',#{is_holiday},\"#{person.full_name}\",'#{department.department_name if department}','#{division.name if division}',null,#{work_length},#{(overtime_in_minutes.to_f - special_overtime.to_f)/60.0},'#{presence.updated_at.utc.to_s(:db)}','#{shift_code}', null, #{special_overtime.to_f/60.0}"
            end
          end
          unless absences.blank?
            absences.each do |absence|
              shift = person.current_shift(absence.absence_date)
              shift_code = shift.blank? ? "-" : shift.shift_code
              department = person.department(absence.absence_date)
              division = person.division(absence.absence_date)
              absence_type = absence.absence_type
              absence_type_code = absence_type.absence_type_code
              absence_type_id = absence_type.type_id
              non_workday = person.current_schedule(absence.absence_date).blank?
              is_holiday = NationalHoliday.is_holiday?(company_id, absence.absence_date) || non_workday
              inserts.push "null,#{absence.id},#{person.company_id},#{department.blank? ? "null":department.id},#{division.blank? ? "null":division.id},#{person.id},'#{person.employee_identification_number.to_s}','#{absence.absence_date.to_s(:db)}',#{is_holiday},\"#{person.full_name}\",'#{department.department_name if department}','#{division.name if division}','#{absence_type_code}',null,null,'#{absence.updated_at.utc.to_s(:db)}','#{shift_code}',#{absence_type_id.blank? ? "null": absence_type_id}, null"
            end
          end
          unless inserts.blank?
            PresenceReport.transaction do
              inserts.each do |insert|
                sql = "REPLACE INTO presence_reports (`presence_id`, `absence_id`, `company_id`, `department_id`, `division_id`, `person_id`, `employee_id`, `date`, `is_holiday`, `full_name`, `department_name`, `division_name`, `absence_code`, `work_duration`, `overtime_duration`,`updated_at`,`shift_code`,`absence_type_id`,`special_overtime`) VALUES (#{insert})"
                PresenceReport.connection.execute sql
              end
            end
            inserted += inserts.length
            inserts = []
          end
          presence_dates = presences.map(&:presence_date)
          absence_dates = absences.map(&:absence_date)
          free_dates = (start_date..end_date).to_a - (absence_dates + presence_dates).uniq
          free_dates.each do |date|
            presence_report = PresenceReport.first(:conditions => ['person_id = ? AND date = ?',person.id, date])
            employment = person.employment(date)
            if !employment.blank? && presence_report.blank?
              shift = person.current_shift(date)
              shift_code = shift.blank? ? "-" : shift.shift_code
              department = person.department(date)
              division = person.division(date)
              non_workday = person.current_schedule(date).blank?
              is_holiday = NationalHoliday.is_holiday?(company_id, date) || non_workday
              absence_code = "-"
              if is_holiday
                absence_code = "L"
              end
              inserts.push "null,null,#{person.company_id},#{department.blank? ? "null":department.id},#{division.blank? ? "null":division.id},#{person.id},'#{person.employee_identification_number.to_s}','#{date.to_s(:db)}',#{is_holiday},\"#{person.full_name}\",'#{department.department_name if department}','#{division.name if division}','#{absence_code}',null,null,'#{Time.now.utc.to_s(:db)}','#{shift_code}',null,null"
            end
          end
          unless inserts.blank?
            PresenceReport.transaction do
              inserts.each do |insert|
                sql = "REPLACE INTO presence_reports (`presence_id`, `absence_id`, `company_id`, `department_id`, `division_id`, `person_id`, `employee_id`, `date`, `is_holiday`, `full_name`, `department_name`, `division_name`, `absence_code`, `work_duration`, `overtime_duration`,`updated_at`,`shift_code`,`absence_type_id`,`special_overtime`) VALUES (#{insert})"
                PresenceReport.connection.execute sql
              end
            end
            inserted += inserts.length
          end
        end
        scheduler_log.debug "-- #{Time.now.strftime("%F %H:%M:%S")} - #{inserted} Records Inserted or Updated to Presence Reports on Company #{company_id}"
        result << {:company => company_id, :status => true}
      else
        scheduler_log.debug "-- #{Time.now.strftime("%F %H:%M:%S")} - No data affected on Company #{company_id}"
        result << {:company => company_id, :status => false}
      end
    end
    scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Insert Presence Report Ended"
    return result
  end

  # Update report setelah update presence, absence, overtime.
  def self.update_report(data, type = 0)
    # 0 = Presence, 1 = Absence, 2 = Overtime
    person = data.person
    case type
    when 0
      date = data.presence_date
      presence_report = PresenceReport.first(:conditions => ['person_id = ? AND date = ?',person.id,date])
      unless presence_report.blank?
        PresenceReport.connection.execute "UPDATE presence_reports SET `presence_id` = #{data.id}, `work_duration` = #{data.net_worktime.to_f}, `absence_id` = null, `absence_code` = null,`absence_type_id` = null WHERE `person_id` = #{person.id} AND `date` = '#{date.to_s(:db)}'"
      else
        shift = person.current_shift(date)
        shift_code = shift.blank? ? "-" : shift.shift_code
        department = person.department(date)
        division = person.division(date)
        non_workday = person.current_schedule(date).blank?
        is_holiday = NationalHoliday.is_holiday?(person.company_id,date) || non_workday
        insert = "#{data.id},#{person.company_id},#{department.blank? ? "null":department.id},#{division.blank? ? "null":division.id},#{person.id},'#{person.employee_identification_number.to_s}','#{date.to_s(:db)}',#{is_holiday},\"#{person.full_name}\",'#{department.department_name if department}','#{division.name if division}',#{data.net_worktime.to_f},'#{shift_code}'"
        PresenceReport.connection.execute "INSERT INTO presence_reports (`presence_id`,`company_id`,`department_id`,`division_id`,`person_id`,`employee_id`,`date`,`is_holiday`,`full_name`,`department_name`,`division_name`,`work_duration`,`shift_code`) VALUES (#{insert})"
      end
    when 1
      date = data.absence_date
      absence_type = data.absence_type
      absence_type_code = absence_type.absence_type_code
      absence_type_id = absence_type.type_id
      presence_report = PresenceReport.first(:conditions => ['person_id = ? AND date = ?',person.id,date])
      unless presence_report.blank?
        PresenceReport.connection.execute "UPDATE presence_reports SET `presence_id` = null, `work_duration` = null, `absence_id` = #{data.id}, `absence_code` = '#{absence_type_code}',`absence_type_id` = #{absence_type_id.blank? ? "null": absence_type_id}, `special_overtime` = null, `overtime_duration` = null WHERE `person_id` = #{person.id} AND `date` = '#{date.to_s(:db)}'"
      else
        shift = person.current_shift(date)
        shift_code = shift.blank? ? "-" : shift.shift_code
        department = person.department(date)
        division = person.division(date)
        non_workday = person.current_schedule(date).blank?
        is_holiday = NationalHoliday.is_holiday?(person.company_id,date) || non_workday
        insert = "#{data.id},#{person.company_id},#{department.blank? ? "null":department.id},#{division.blank? ? "null":division.id},#{person.id},'#{person.employee_identification_number.to_s}','#{date.to_s(:db)}',#{is_holiday},\"#{person.full_name}\",'#{department.department_name if department}','#{division.name if division}','#{absence_type_code}','#{shift_code}',#{absence_type_id.blank? ? "null": absence_type_id}"
        PresenceReport.connection.execute "INSERT INTO presence_reports (`absence_id`,`company_id`,`department_id`,`division_id`,`person_id`,`employee_id`,`date`,`is_holiday`,`full_name`,`department_name`,`division_name`,`absence_code`,`shift_code`,`absence_type_id`) VALUES (#{insert})"
      end
    when 2
      date = data.overtime_date
      overtime_duration = person.overtimes.sum(:overtime_length_in_minutes, :conditions => ['overtime_date = ? AND overtime_status = ?', date, "Approved"])
      special_overtime = person.overtimes.sum(:overtime_length_in_minutes, :conditions => ['overtime_date = ? AND overtime_status = ? AND overtime_type LIKE ?', date, "Approved", "%Lembur Khusus%"])
      PresenceReport.connection.execute "UPDATE presence_reports SET  `special_overtime` = #{special_overtime/60.0}, `overtime_duration` = #{(overtime_duration - special_overtime)/60.0} WHERE `person_id` = #{person.id} AND `date` = '#{date.to_s(:db)}'"
    end
  end

  def self.update_by_shift(shift_update)
    if shift_update.class == Array
      employee_shifts = shift_update
      shift_code = shift_update.first.shift.shift_code if !shift_update.first.nil?
    else
      employee_shifts = shift_update.employee_shifts
      shift_code = shift_update.shift_code
    end
    updates = []
    employee_shifts.each do |employee_shift|
      person = Person.find(employee_shift.person_id)
      presence_reports = PresenceReport.all(:conditions => ['person_id = ? AND date BETWEEN ? AND ?', person.id, employee_shift.shift_from, employee_shift.shift_to])
      presence_reports.each do |updated_report|
        non_workday = person.current_schedule(updated_report.date).blank?
        is_holiday = NationalHoliday.is_holiday?(person.company_id,updated_report.date) || non_workday
        updates.push "UPDATE presence_reports SET  `is_holiday` = #{is_holiday}, `shift_code` = '#{shift_code}' WHERE `person_id` = #{person.id} AND `date` = '#{updated_report.date.to_s(:db)}'"
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

  def self.destroy_raw_data
    ActiveRecord::Base.connection.execute("TRUNCATE presence_reports")
  end

  def self.count_overtimes_this_week
    logfile = File.open("#{RAILS_ROOT}/log/scheduler.log", 'a')
    logfile.sync = true
    scheduler_log = Logger.new(logfile)
    scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Update total overtime this week started"
    company_ids = User.all.map(&:company_id).uniq
    company_ids.each do |company_id|
      people = Person.all(:conditions => ['company_id = ?', company_id])
      updates = []
      inserts = []
      people.each do |person|
        presence_reports = PresenceReport.all(:conditions => ['person_id = ?', person.id], :order => 'date')
        unless presence_reports.blank?
          date_start = presence_reports.first.date
          date_end = Date.today
          overtime_this_week = 0.0
          holiday_overtime = 0.0
          worktime = 0.0
          uncount_overtime = 0.0
          sun_overtime = 0.0
          shift = person.current_shift(date_start)
          (date_start..date_end).each do |date|
            report = presence_reports.find{|r| r.date == date}
            if date.wday == 4
              shift = person.current_shift(date)
            end
            unless report.blank?
              overtime_this_week += report.special_overtime.to_f * 2
              unless report.is_holiday
                worktime += report.work_duration.to_f
                sun_overtime = report.overtime_duration.to_f
                if report.overtime_duration.to_f > 1
                  overtime_this_week += 1.5
                  overtime_this_week += (report.overtime_duration.to_f - 1) * 2
                else
                  overtime_this_week += report.overtime_duration.to_f * 1.5
                end
              else
                holiday_overtime += report.overtime_duration.to_f
              end
            end
            if date.wday == 0
              if shift && shift.total_hours.to_f > shift.working_hour_per_week
                if worktime > shift.total_hours.to_f
                  uncount_overtime = shift.total_hours.to_f - shift.working_hour_per_week.to_f
                else
                  uncount_overtime = worktime - shift.working_hour_per_week.to_f
                  uncount_overtime = 0.0 if uncount_overtime < 0.0
                end
              end
              if holiday_overtime > 8
                overtime_this_week += (holiday_overtime - 8) * 4
                overtime_this_week += 1 * 3
                overtime_this_week += 7 * 2
              elsif holiday_overtime > 7
                overtime_this_week += (holiday_overtime - 7) * 3
                overtime_this_week += 7 * 2
              else
                overtime_this_week += holiday_overtime * 2
              end
              if uncount_overtime > 0
                if sun_overtime > 1
                  overtime_this_week += uncount_overtime * 2
                else
                  overtime_this_week += (1 - sun_overtime) * 1.5
                  overtime_this_week += (uncount_overtime - (1 - sun_overtime)) * 2
                end
              end
              unless report.blank?
                updates.push "UPDATE presence_reports SET  `total_overtime_this_week` = #{overtime_this_week.to_f}, `unaccounted_noncompulsory_overtime` = #{uncount_overtime.to_f} WHERE `person_id` = #{person.id} AND `date` = '#{date.to_s(:db)}'"
              else
                if overtime_this_week > 0 || uncount_overtime > 0
                  shift_code = shift.blank? ? "-" : shift.shift_code
                  department = person.department(date)
                  division = person.division(date)
                  insert = "#{person.company_id},#{department.blank? ? "null":department.id},#{division.blank? ? "null":division.id},#{person.id},'#{person.employee_identification_number.to_s}','#{date.to_s(:db)}',\"#{person.full_name}\",'#{department.department_name if department}','#{division.name if division}', '#{shift_code}', #{overtime_this_week.to_f}, #{uncount_overtime.to_f}"
                  inserts.push "INSERT INTO presence_reports (`company_id`,`department_id`,`division_id`,`person_id`,`employee_id`,`date`,`full_name`,`department_name`,`division_name`,`shift_code`, `total_overtime_this_week`, `unaccounted_noncompulsory_overtime`) VALUES (#{insert})"
                end
              end
              worktime = 0.0
              overtime_this_week = 0.0
              holiday_overtime = 0.0
              uncount_overtime = 0.0
              sun_overtime = 0.0
            end
          end
        end
      end
      unless updates.blank? && inserts.blank?
        PresenceReport.transaction do
          inserts.each do |insert|
            PresenceReport.connection.execute insert
          end unless inserts.blank?
          updates.each do |update|
            PresenceReport.connection.execute update
          end unless updates.blank?
        end
      end
    end
    scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Update total overtime this week finished"
  end

  def self.count_overtimes_this_week_by_company_id(company_id)
    logfile = File.open("#{RAILS_ROOT}/log/scheduler.log", 'a')
    logfile.sync = true
    scheduler_log = Logger.new(logfile)
    scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Update total overtime this week started"
    unless company_id.blank?
      people = Person.all(:conditions => ['company_id = ?', company_id])
      updates = []
      inserts = []
      people.each do |person|
        presence_reports = PresenceReport.all(:conditions => ['person_id = ?', person.id], :order => 'date')
        unless presence_reports.blank?
          date_start = presence_reports.first.date
          date_end = Date.today
          overtime_this_week = 0.0
          holiday_overtime = 0.0
          worktime = 0.0
          uncount_overtime = 0.0
          sun_overtime = 0.0
          shift = person.current_shift(date_start)
          (date_start..date_end).each do |date|
            report = presence_reports.find{|r| r.date == date}
            if date.wday == 4
              shift = person.current_shift(date)
            end
            unless report.blank?
              overtime_this_week += report.special_overtime.to_f * 2
              unless report.is_holiday
                worktime += report.work_duration.to_f
                sun_overtime = report.overtime_duration.to_f
                if report.overtime_duration.to_f > 1
                  overtime_this_week += 1.5
                  overtime_this_week += (report.overtime_duration.to_f - 1) * 2
                else
                  overtime_this_week += report.overtime_duration.to_f * 1.5
                end
              else
                holiday_overtime += report.overtime_duration.to_f
              end
            end
            if date.wday == 0
              if shift && shift.total_hours.to_f > shift.working_hour_per_week
                if worktime > shift.total_hours.to_f
                  uncount_overtime = shift.total_hours.to_f - shift.working_hour_per_week.to_f
                else
                  uncount_overtime = worktime - shift.working_hour_per_week.to_f
                  uncount_overtime = 0.0 if uncount_overtime < 0.0
                end
              end
              if holiday_overtime > 8
                overtime_this_week += (holiday_overtime - 8) * 4
                overtime_this_week += 1 * 3
                overtime_this_week += 7 * 2
              elsif holiday_overtime > 7
                overtime_this_week += (holiday_overtime - 7) * 3
                overtime_this_week += 7 * 2
              else
                overtime_this_week += holiday_overtime * 2
              end
              if uncount_overtime > 0
                if sun_overtime > 1
                  overtime_this_week += uncount_overtime * 2
                else
                  overtime_this_week += (1 - sun_overtime) * 1.5
                  overtime_this_week += (uncount_overtime - (1 - sun_overtime)) * 2
                end
              end
              unless report.blank?
                updates.push "UPDATE presence_reports SET  `total_overtime_this_week` = #{overtime_this_week.to_f}, `unaccounted_noncompulsory_overtime` = #{uncount_overtime.to_f} WHERE `person_id` = #{person.id} AND `date` = '#{date.to_s(:db)}'"
              else
                if overtime_this_week > 0 || uncount_overtime > 0
                  shift_code = shift.blank? ? "-" : shift.shift_code
                  department = person.department(date)
                  division = person.division(date)
                  insert = "#{person.company_id},#{department.blank? ? "null":department.id},#{division.blank? ? "null":division.id},#{person.id},'#{person.employee_identification_number.to_s}','#{date.to_s(:db)}',\"#{person.full_name}\",'#{department.department_name if department}','#{division.name if division}', '#{shift_code}', #{overtime_this_week.to_f}, #{uncount_overtime.to_f}"
                  inserts.push "INSERT INTO presence_reports (`company_id`,`department_id`,`division_id`,`person_id`,`employee_id`,`date`,`full_name`,`department_name`,`division_name`,`shift_code`, `total_overtime_this_week`, `unaccounted_noncompulsory_overtime`) VALUES (#{insert})"
                end
              end
              worktime = 0.0
              overtime_this_week = 0.0
              holiday_overtime = 0.0
              uncount_overtime = 0.0
              sun_overtime = 0.0
            end
          end
        end
      end
      unless updates.blank? && inserts.blank?
        PresenceReport.transaction do
          inserts.each do |insert|
            PresenceReport.connection.execute insert
          end unless inserts.blank?
          updates.each do |update|
            PresenceReport.connection.execute update
          end unless updates.blank?
        end
      end
    end
    scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Update total overtime this week finished"
  end

end
