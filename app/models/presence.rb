# == Schema Information
#
# Table name: presences
#
#  id                       :integer(4)      not null, primary key
#  company_id               :integer(4)
#  person_id                :integer(4)
#  presence_date            :date
#  presence_length_in_hours :decimal(8, 4)
#  paid_hours               :decimal(8, 4)
#  break_length_in_minutes  :integer(4)
#  presence_status          :string(255)
#  presence_description     :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  is_acted_upon            :integer(4)
#  moved_worktime_in_hours  :decimal(8, 4)
#

class Presence < ActiveRecord::Base
  belongs_to :person
  has_many :presence_details, :dependent => :destroy
  validates_uniqueness_of :presence_date, :scope => :person_id
  after_save :update_presence_report
  after_save :update_recurring_sick
  after_destroy :clear_overtime_and_report

  def set_is_acted_upon(action)
    self.is_acted_upon = self.is_acted_upon.to_i | action
    self.save!
  end

  def is_acted_upon?(action)
    return !((self.is_acted_upon.to_i & action) == 0)
  end

  def balance_time(num)
    hour = num.to_f/60
    self.update_attribute("presence_length_in_hours",self.presence_length_in_hours - hour)
  end

  # Insert ke table presence hanya bila belum ada
  # status by default 'Approved', paid_hours = presence_length_in_hours
  # insert satu row ke tabel presence_details
  def self.login(person, time=Time.now)
    date = time.getlocal.to_date
    sched_time = person.current_schedule(date.yesterday)
    unless sched_time.blank?
      if sched_time[:schedule_start].getlocal.to_date != sched_time[:schedule_end].getlocal.to_date
        # jika masih dalam jadwal kemarin tanggal = tanggal kemarin.
        date = date.yesterday if time.utc < sched_time[:schedule_end]
      end
    end
    presence = person.presences.find_by_presence_date(date)
    absence = person.absences.find_by_absence_date(date)
    if absence.blank?
      if presence.blank?
        presence = person.presences.create({:presence_date => date, :company_id => person.company_id, :presence_status => 'Approved'})
        presence_detail = presence.presence_details.new
        presence_detail.start_working = time
        presence_detail.save!
      else
        if presence.is_acted_upon.blank? || !presence.is_acted_upon?(256)
          last_detail = presence.presence_details.first(:conditions =>['start_working is null AND ? < end_working', time.utc], :order => :end_working)
          if last_detail.blank?
            presence_detail = presence.presence_details.first(:conditions => ['start_working = ?', time.utc])
            if presence_detail.blank?
              presence_detail = presence.presence_details.new
              presence_detail.start_working = time
              presence_detail.save!
            else
              return false
            end
          else
            last_detail = presence.presence_details.first(:conditions =>['start_working is null AND ? < end_working', time.utc], :order => :end_working)
            last_detail.start_working = time
            last_detail.save!
          end
        end
      end
    else
      return false
    end
    return presence
  end

  # Apabila sudah ada 'detail' pada hari tersebut, maka dicek detail terakhirnya:
  # A apabila end_working nya NULL, maka update end_working nya
  # B apabila end_working nya tidak NULL, maka INSERT satu row baru untuk details
  # Dalam kasus B, maka row baru tersebut harus diisi 'breaktime_in_minutes' nya
  #
  # Bila pada saat logout, dia bekerja lebih namum memang diwajibkan lembur, maka otomatis panggil approve_overtime
  # Atau juga bila dia jabatannya supir maka panggil approve_overtime juga
  def self.logout(person, time = Time.now, rest_length=nil)
    date = time.getlocal.to_date
    presence = person.presences.find_by_presence_date(date)
    yesterday_presence = person.presences.find_by_presence_date(date.yesterday)
    sched_time = person.current_schedule(date)
    if presence
      if presence.is_acted_upon.blank? || !presence.is_acted_upon?(256)
        last_presence_detail = presence.presence_details.last(:conditions => ['start_working is not null AND end_working is null AND start_working < ?', time.utc], :order => :start_working)
        presence_details = presence.presence_details
        if presence_details.blank?
          last_presence_detail = presence.presence_details.create
        else
          this_presence_detail = presence_details.find_all{|x| x.end_working == time.utc}
          this_yesterday_detail = yesterday_presence.presence_details.last(:conditions => ['end_working is null OR end_working = ?', time.utc]) if yesterday_presence
          if (this_presence_detail.blank? && this_yesterday_detail.blank?) && last_presence_detail.blank?
            last_presence_detail = presence.presence_details.create
          end
        end
      end
    end
    if yesterday_presence && last_presence_detail.blank?
      sched_time = person.current_schedule(date.yesterday)
      presence = yesterday_presence
      if presence.is_acted_upon.blank? || !presence.is_acted_upon?(256)
        if sched_time && (sched_time[:schedule_start].getlocal.to_date != sched_time[:schedule_end].getlocal.to_date)
          last_presence_detail = presence.presence_details.last(:conditions => ['start_working is not null AND end_working is null AND start_working < ?', time.utc], :order => :start_working)
          presence_details = presence.presence_details
          if presence_details.blank?
            last_presence_detail = presence.presence_details.create
          else
            this_presence_detail = presence_details.find_all{|x| x.end_working == time.utc}
            if this_presence_detail.blank? && last_presence_detail.blank?
              last_presence_detail = presence.presence_details.create
            end
          end
        else
          last_presence_detail = presence.presence_details.last(:conditions => ['start_working is not null AND end_working is null AND start_working < ?', time.utc], :order => :start_working)
          this_presence_detail = presence.presence_details.first(:conditions => ['end_working = ? ', time.utc])
          unless this_presence_detail.blank?
            last_presence_detail = nil
          end
        end
      end
    end
    unless last_presence_detail.blank?
      last_presence_detail.update_attributes(:end_working => time)
      # Hitung waktu ketika absen keluar
      unless last_presence_detail.start_working.blank?
        last_presence_detail.calculate_time(rest_length)
      end
      presence.calculate_work_time(rest_length)
      # Hitung waktu kerja
      if sched_time && sched_time[:schedule_length].to_f > 0
        presence.calculate_overtime
      end
    else
      if presence.blank?
        presence = person.presences.create({:presence_date => date, :company_id => person.company_id, :presence_status => 'Approved'})
        presence_detail = presence.presence_details.new
        presence_detail.end_working = time
        presence_detail.save!
      else
        return false
      end
    end
    return presence
  end

  def self.logout_manual(person, time=Time.now)
    date = time.getlocal.to_date
    presence = person.presences.find_by_presence_date(date)
    if presence
      last_presence_detail = presence.presence_details.last(:conditions => ['start_working is not null AND end_working is null AND start_working < ?', time.utc], :order => :start_working)
      unless last_presence_detail.blank?
        last_presence_detail.update_attributes(:end_working => time)
        # Hitung waktu ketika absen keluar
        unless last_presence_detail.start_working.blank?
          last_presence_detail.calculate_time
        end
        presence.calculate_work_time
        # Hitung waktu kerja
      end
    end
    return presence
  end

  # Method yang dirunning scheduler setiap 6 jam
  def self.device_import
    logfile = File.open("#{RAILS_ROOT}/log/scheduler.log", 'a')
    logfile.sync = true
    scheduler_log = Logger.new(logfile)
    scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Move data from Temporary Table to Presences started"
    company_ids = User.all.map(&:company_id).uniq
    company_ids.each do |company_id|
      total_record = 0
      raw_presences = RawPresence.all(:conditions=>['company_id = ? AND is_imported = ?', company_id, false], :order => :presence_time)
      unless raw_presences.blank?
        raw_presences.each do |raw_data|
          #Find first antisipasi fingerprint_user not unique
          person = Person.find(:first, :conditions => ['fingerprint_user = ? AND company_id = ?',raw_data.reg_id, raw_data.company_id])
          unless person.blank?
            if raw_data.status == 0
              Presence.login(person,raw_data.presence_time)
            else
              Presence.logout(person,raw_data.presence_time)
            end
            raw_data.is_imported = true
            raw_data.save(false)
            total_record += 1
          end
        end
        scheduler_log.debug "--- #{Time.now.strftime("%Y-%m-%d %H:%M:%S")} #{total_record} Data processed for company id #{company_id}"
      else
        scheduler_log.debug "--- #{Time.now.strftime("%Y-%m-%d %H:%M:%S")} None Data processed for company id #{company_id}"
      end
    end
    scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Move data from Temporary Table to Presences finished"
  end

  def self.device_import_by_company_id(company_id)
    logfile = File.open("#{RAILS_ROOT}/log/scheduler.log", 'a')
    logfile.sync = true
    scheduler_log = Logger.new(logfile)
    scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Move data from Temporary Table to Presences started"
    unless company_id.blank?
      total_record = 0
      raw_presences = RawPresence.all(:conditions=>['company_id = ? AND is_imported = ?', company_id, false], :order => :presence_time)
      unless raw_presences.blank?
        raw_presences.each do |raw_data|
          #Find first antisipasi fingerprint_user not unique
          person = Person.find(:first, :conditions => ['fingerprint_user = ? AND company_id = ?',raw_data.reg_id, raw_data.company_id])
          unless person.blank?
            if raw_data.status == 0
              Presence.login(person,raw_data.presence_time)
            else
              Presence.logout(person,raw_data.presence_time)
            end
            raw_data.is_imported = true
            raw_data.save(false)
            total_record += 1
          end
        end
        scheduler_log.debug "--- #{Time.now.strftime("%Y-%m-%d %H:%M:%S")} #{total_record} Data processed for company id #{company_id}"
      else
        scheduler_log.debug "--- #{Time.now.strftime("%Y-%m-%d %H:%M:%S")} None Data processed for company id #{company_id}"
      end
    end
    scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Move data from Temporary Table to Presences finished"
  end

  # Method untuk memindahkan presence detail ke hari kemarin sesuai dengan jadwal kerjanya
  def moving_details
    person = self.person
    date = self.presence_date
    details = self.presence_details
    unless details.blank?
      yesterday_presence = person.presences.find_by_presence_date(date.yesterday)
      yesterday_sched_time = person.current_schedule(date.yesterday)
      sched_time = person.current_schedule(date)
      if sched_time && yesterday_sched_time
        details.each do |detail|
          if detail.start_working
            if (detail.start_working - sched_time[:schedule_start]).abs > (detail.start_working - yesterday_sched_time[:schedule_start]).abs
              yesterday_presence = person.presences.create(:company_id => self.company_id,
                :presence_date => date.yesterday) if yesterday_presence.blank?
              detail.presence = yesterday_presence
              if detail.save!
                self.calculate_work_time
                yesterday_presence.calculate_work_time
              end
            end
          elsif detail.end_working
            if (detail.end_working - sched_time[:schedule_end]).abs > (detail.end_working - yesterday_sched_time[:schedule_end]).abs
              yesterday_presence = person.presences.create(:company_id => self.company_id,
                :presence_date => date.yesterday) if yesterday_presence.blank?
              detail.presence = yesterday_presence
              if detail.save!
                self.calculate_work_time
                yesterday_presence.calculate_work_time
              end
            end
          end
          self.destroy if self.presence_details.blank?
        end unless details.blank?
      end
    end
  end

  def calculate_work_time(rest_length=nil)
    unless self.presence_details.blank?
      worklength = 0
      self.break_length_in_minutes = 0 unless self.is_acted_upon?(24)
      hr_setting = HrSetting.find_by_company_id(self.company_id)
      presence_details = self.presence_details.all(:conditions =>['start_working is not null AND end_working is not null'], :order => 'start_working')
      first_detail = presence_details.first
      last_detail = presence_details.last
      presence_details.each_with_index do |detail, index|
        worklength += detail.work_session_length_in_minutes.to_i
        if index > 0 && !self.is_acted_upon?(24)
          if detail.start_working && presence_details[index-1].end_working
            break_time = (detail.start_working - presence_details[index-1].end_working)/60.to_i
            self.update_attributes :break_length_in_minutes => self.break_length_in_minutes.to_i + break_time
          end
        end
      end
      if rest_length
        self.update_attributes :break_length_in_minutes => rest_length if rest_length > 0
      end
      unless last_detail.blank?
        if self.is_acted_upon?(1)
          person = self.person
          schedule = person.current_schedule(self.presence_date)
          worklength = ((last_detail.end_working - (schedule[:schedule_start] + first_detail.lateness_in_minutes.to_i.minutes))/60) - self.break_length_in_minutes.to_i
        else
          worklength = (last_detail.end_working - first_detail.start_working)/60 - self.break_length_in_minutes.to_i
        end
        self.update_attributes :presence_length_in_hours => (worklength - self.moved_worktime_in_hours.to_f * 60) / 60.to_f
        self.update_attributes :net_worktime => ((self.presence_length_in_hours * 60) / hr_setting.period_in_minutes ).floor * hr_setting.period_in_minutes / 60.to_f
        self.update_attributes :paid_hours => (self.presence_length_in_hours.to_f * 60 / hr_setting.period_in_minutes ).floor * hr_setting.period_in_minutes / 60.to_f
      end
    end
  end

  # Perhitungan Jam kerja lebih untuk lembur
  def calculate_overtime(compulsory=true)
    person = self.person
    company_id = person.company_id
    hr_setting = HrSetting.last(:conditions => {:company_id => company_id})
    periode = hr_setting.period_in_minutes
    # Get user schedule
    sched_time = person.current_schedule(self.presence_date)
    is_holiday = NationalHoliday.is_holiday?(company_id,self.presence_date)
    overtime = person.overtimes.find(:last, :conditions => ['overtime_date = ? AND overtime_type = "Lembur Wajib"', self.presence_date])
    if sched_time && !is_holiday
      if compulsory
        work_length = sched_time[:schedule_length]
        compulsory_overtime = sched_time[:compulsory_overtime]
        # Check/hitung lama kerja dengan total jam kerja yg ada di schedule.
        overtime_length = self.presence_length_in_hours.to_f * 60 - (work_length.to_f * 60)
        if overtime_length > periode
          if compulsory_overtime.to_i > 0
            overtime = person.overtimes.new({:company_id => person.company_id, :overtime_date => self.presence_date}) if overtime.blank?
            unless overtime.overtime_length_in_minutes.to_i == compulsory_overtime.to_i
              if overtime_length > compulsory_overtime.to_i
                overtime.overtime_length_in_minutes = compulsory_overtime.to_i
              else
                overtime.overtime_length_in_minutes = (overtime_length/periode).floor * periode
              end
              overtime.start_overtime = sched_time[:schedule_end] - compulsory_overtime.to_i.minutes
              overtime.end_overtime = overtime.start_overtime + overtime.overtime_length_in_minutes.minutes
              overtime.overtime_status = "Approved"
              overtime.overtime_type = "Lembur Wajib"
              overtime.save!
            end
          end
        end
      end
    end
  end

  # Apakah terlambat?
  def is_late
    person = self.person
    company_id = self.company_id
    hr_setting = HrSetting.last(:conditions => {:company_id => company_id})
    tolerance = hr_setting.blank? ? 0 : hr_setting.lateness_tolerance_in_minutes
    sched_time = person.current_schedule(self.presence_date) unless person.blank?
    if sched_time
      start_schedule = sched_time[:schedule_start] + tolerance.to_i.minutes
      first_presence_detail = self.presence_details.first(:conditions => ['start_working is not null'], :order => 'start_working')
      if first_presence_detail
        time_come_to_work = first_presence_detail.start_working
        late_time = first_presence_detail.lateness_in_minutes
        is_acted_upon = self.is_acted_upon?(1)
      else
        time_come_to_work = Time.now
      end
      late_time = ((time_come_to_work - start_schedule)/60).to_i if late_time.nil? && !time_come_to_work.nil?
      if (!late_time.nil? && late_time > 0 && !time_come_to_work.nil?) || is_acted_upon
        return late_time
      else
        return false
      end
    else
      return false
    end
  end

  def self.sequential_late(company_id)
    people = Person.all(:conditions => ["company_id = ?", company_id])
    total = 0
    people.each do |person|
      date = Date.today
      presence = person.presences.find_by_presence_date(date)
      if presence && presence.is_late
        date = date.yesterday
        while person.current_schedule(date).blank? || person.current_schedule(date)[:schedule_length] == 0
          date = date.yesterday
        end
        presence = person.presences.find_by_presence_date(date)
        total += 1 if presence && presence.is_late
      end
    end
    return total
  end

  # jam datang - person.current_employment.shift.on_day('Monday').start_time > tolerance di hr_setting
  def self.late_comers(company_id, start_date, end_date, options={})
    #    presences = find(:all, :conditions => ['company_id = ? AND presence_date BETWEEN ? AND ?', company_id, start_date, end_date])
    presences = who_is_working(company_id, start_date, end_date, options)
    late_presences = []
    hr_setting = HrSetting.last(:conditions => {:company_id => company_id})

    # Add conditions for company who doesn't have hr_setting yet
    tolerance = hr_setting.blank? ? 0 : hr_setting.lateness_tolerance_in_minutes
    presences.each do |presence|
      person = presence.person
      sched_time = person.current_schedule(presence.presence_date)
      if sched_time
        start_schedule = sched_time[:schedule_start] + tolerance.minutes
        late_detail = presence.presence_details.first(:conditions => ['start_working is not null'], :order => 'start_working')
        if late_detail
          time_come_to_work = late_detail.start_working
          late_time = late_detail.lateness_in_minutes
        end
        unless time_come_to_work
          time_come_to_work = start_schedule + 1.second
        end
        late_time = ((time_come_to_work - start_schedule)/60).to_i unless late_time
        if late_time.to_i > 0 || presence.is_acted_upon?(1)
          department = person.department(presence.presence_date)
          division = person.division(presence.presence_date)
          late_presences << { :late_id => presence.id, :person_id => person.id, :person_name => person.full_name, :date => presence.presence_date,
            :start_work => time_come_to_work.getlocal, :department => department, :division => division,
            :late_time => late_time,
            :late_reason => (late_detail.lateness_reason if late_detail),
            :status => presence.presence_status, :shift_name => sched_time[:shift_name],
            :is_acted_upon => presence.is_acted_upon?(1)
          }
        end
      end
    end
    return late_presences
  end

  def self.who_is_working(company_id, start_date, end_date, options={})
    people = people_filter(company_id, start_date, end_date, options)
    if options[:person] == true
      return people
    else
      people_id = people.map{|p| p.id}
      if (start_date.blank? && end_date.blank?)
        return find(:all,:include=> :person, :conditions => ["presences.person_id IN (?)", people_id])
      else
        return find(:all,:include=> :person, :conditions => ["presences.person_id IN (?) AND presences.presence_date BETWEEN ? AND ?", people_id, start_date, end_date], :order => 'people.firstname ASC, people.lastname ASC')
      end
    end
  end

  # Bukan hanya yang jam kerjanya lebih, tapi juga yang bekerja namun seharusnya tidak bekerja
  def self.worktime_more_than_normal(company_id, start_date, end_date, options={})
    #    presences = find(:all, :conditions => ['company_id = ? AND presence_date BETWEEN ? AND ?', company_id, start_date, end_date])
    presences = who_is_working(company_id, start_date, end_date, options)
    hr_setting = HrSetting.last(:conditions => {:company_id => company_id})
    more_than_normal = []
    presences.each do |presence|
      completed_work = true
      person = presence.person
      schedule = person.current_schedule(presence.presence_date)
      first_detail = presence.presence_details.first
      last_detail = presence.presence_details.last
      unless first_detail.blank?
        end_work = last_detail.end_working
        if first_detail.start_working.blank? || end_work.blank?
          completed_work = false
        end
        department = person.department(presence.presence_date)
        division = person.division(presence.presence_date)
        holiday = NationalHoliday.is_holiday?(person.company_id, presence.presence_date)
        if holiday && completed_work
          more_than_normal << { :more_id => presence.id, :person_id => person.id, :person_name => person.full_name,
            :date => presence.presence_date,
            :department => (department.department_name if department),
            :division => (division.name if division),
            :start_work => (first_detail.start_working.getlocal if first_detail.start_working),
            :end_work => (end_work.getlocal if end_work),
            :work_length => presence.net_worktime.to_f,
            :break_length => presence.break_length_in_minutes.to_i,
            :status => presence.presence_status,
            :is_acted_upon => presence.is_acted_upon?(2)
          }
        elsif schedule && completed_work
          standard_duration = schedule[:schedule_length] + (schedule[:compulsory_overtime] / 60.to_f )
          if presence.net_worktime && (presence.net_worktime.to_f > (standard_duration + hr_setting.period_in_minutes / 60.to_f) ) && !first_detail.start_working.blank? && !end_work.blank?
            more_than_normal << { :more_id => presence.id, :person_id => person.id, :person_name => person.full_name,
              :date => presence.presence_date,
              :department => (department.department_name if department),
              :division => (division.name if division),
              :start_work => (first_detail.start_working.getlocal if first_detail.start_working),
              :end_work => (end_work.getlocal if end_work),
              :work_length => presence.net_worktime.to_f,
              :break_length => presence.break_length_in_minutes.to_i,
              :status => presence.presence_status,
              :is_acted_upon => presence.is_acted_upon?(2)
            }
          end
        elsif completed_work
          more_than_normal << { :more_id => presence.id, :person_id => person.id, :person_name => person.full_name,
            :date => presence.presence_date,
            :department => (department.department_name if department),
            :division => (division.name if division),
            :start_work => (first_detail.start_working.getlocal if first_detail.start_working),
            :end_work => (end_work.getlocal if end_work),
            :work_length => presence.net_worktime.to_f,
            :break_length => presence.break_length_in_minutes.to_i,
            :status => presence.presence_status,
            :is_acted_upon => presence.is_acted_upon?(2)
          }
        end
      end
    end
    return more_than_normal
  end

  def more_hour_as_overtime(duration, overtime_type="Lembur Biasa")
    person = self.person
    first_detail = self.presence_details.first
    overtime = person.overtimes.last(:conditions => ['overtime_date = ?', self.presence_date])
    new_overtime = person.overtimes.new
    if self.presence_length_in_hours >= duration
      new_overtime.overtime_date = self.presence_date
      new_overtime.company_id = self.company_id
      unless overtime
        if first_detail.end_working
          new_overtime.start_overtime = first_detail.end_working
          new_overtime.end_overtime = first_detail.end_working + duration
        end
      else
        new_overtime.start_overtime = overtime.end_overtime
        new_overtime.end_overtime = overtime.end_overtime + duration
      end
      new_overtime.overtime_length_in_minutes = duration * 60
      new_overtime.overtime_status = "Approved"
      new_overtime.overtime_type = overtime_type
      if new_overtime.save!
        self.set_is_acted_upon(2)
        self.save!
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def ignore_more_work
    person = self.person
    schedule = person.current_schedule(self.presence_date)
    rv = false
    unless schedule.blank?
      if self.update_attributes(:net_worktime => schedule[:schedule_length])
        self.set_is_acted_upon(2)
        rv = self
      end
    end
    rv
  end

  def work_in_another_day(date, duration)
    person = self.person
    presence = person.presences.find_by_presence_date(date)
    unless presence
      presence = person.presences.new
      presence.presence_date = date
      presence.company_id = person.company_id
    end
    presence.presence_length_in_hours = presence.presence_length_in_hours.to_f + duration
    presence.net_worktime = presence.net_worktime.to_f + duration
    presence.paid_hours = presence.paid_hours.to_f + duration
    presence.presence_status = "Approved"
    presence.presence_description = "Pindahan data kehadiran dari tanggal #{self.presence_date.strftime("%d/%m/%Y")}"
    presence.break_length_in_minutes = presence.break_length_in_minutes.to_i
    presence.set_is_acted_upon(2)
    presence.save!
    last_detail = presence.presence_details.last
    detail = presence.presence_details.new
    if last_detail
      detail.start_working = last_detail.end_working
      detail.end_working = detail.start_working + duration.hours
    else
      schedule = person.current_schedule(date)
      unless schedule.blank?
        detail.start_working = schedule[:schedule_start]
        detail.end_working = detail.start_working + duration.hours
      else
        detail.start_working = date + 1.minutes
        detail.end_working = detail.start_working + duration.hours
      end
    end
    detail.work_session_length_in_minutes = duration * 60
    detail.save!
    self.moved_worktime_in_hours = duration
    self.set_is_acted_upon(2)
    self.calculate_work_time
  end

  def self.worktime_less_than_normal(company_id, start_date, end_date, options={})
    presences = who_is_working(company_id, start_date, end_date, options)
    #    presences = find(:all, :conditions => ['company_id = ? AND presence_date BETWEEN ? AND ?', company_id, start_date, end_date])
    less_than_normal = []
    presences.each do |presence|
      person = presence.person
      schedule = person.current_schedule(presence.presence_date)
      absen = !person.absences.find_by_absence_date(presence.presence_date).blank?
      holiday = NationalHoliday.is_holiday?(person.company_id, presence.presence_date)
      if schedule && !holiday
        standard_duration = schedule[:schedule_length]
        if presence.net_worktime && (presence.net_worktime.to_f < standard_duration) || presence.is_acted_upon?(4)
          presence_details = presence.presence_details
          if !presence_details.blank? && presence_details.last.end_working && presence_details.first.start_working
            department = person.department(presence.presence_date)
            division = person.division(presence.presence_date)
            end_work = presence.presence_details.last.end_working.getlocal
            less_than_normal << { :less_id => presence.id, :person_id => person.id, :person_name => person.full_name,
              :date => presence.presence_date,
              :department => (department.department_name if department),
              :division => (division.name if division),
              :start_work => presence.presence_details.first.start_working.getlocal,
              :end_work => end_work,
              :work_length => presence.net_worktime.to_f,
              :break_length => presence.break_length_in_minutes.to_i,
              :description => presence.presence_description,
              :status => presence.presence_status,
              :is_acted_upon => presence.is_acted_upon?(4),
              :absen => absen
            }
          end
        end
      end
    end
    return less_than_normal
  end

  def self.more_less_worktime(id)
    presence = find(id)
    person = presence.person
    schedule = person.current_schedule(presence.presence_date)
    holiday = NationalHoliday.is_holiday?(person.company_id, presence.presence_date)
    hr_setting = HrSetting.last(:conditions => {:company_id => person.company_id})
    if schedule && !holiday
      standard_duration = schedule[:schedule_length] + schedule[:compulsory_overtime] / 60.to_f
      more_hour = presence.net_worktime.to_f - standard_duration
      if more_hour > 0
        return {:id => id, :name => person.full_name, :date => presence.presence_date,
          :work_hour => presence.net_worktime, :more_hour => more_hour,
          :standard_work_length => schedule[:schedule_length] }
      else
        return {:id => id, :name => person.full_name, :date => presence.presence_date,
          :standard_work_length => standard_duration, :work_hour => presence.net_worktime}
      end
    else
      more_hour = (presence.presence_length_in_hours.to_f * 60/hr_setting.period_in_minutes).floor * hr_setting.period_in_minutes/60.to_f
      return {:id => id, :name => person.full_name, :date => presence.presence_date,
        :more_hour => more_hour, :work_hour => presence.net_worktime}
    end
  end

  def self.breaktime_more_than_normal(company_id, start_date, end_date, options={})
    presences = who_is_working(company_id, start_date, end_date, options)
    #    presences = find(:all, :conditions => ['company_id = ? AND presence_date BETWEEN ? AND ?', company_id, start_date, end_date])
    break_more_than_normal = []
    presences.each do |presence|
      person = presence.person
      schedule = person.current_schedule(presence.presence_date)
      if schedule
        standard_duration = schedule[:break_length]
        is_acted_upon = presence.is_acted_upon?(8)
        if (!presence.presence_details.first.start_working.blank? && !presence.presence_details.first.end_working.blank?) && (!presence.presence_details.last.start_working.blank? && !presence.presence_details.last.end_working.blank?)
          if (!presence.break_length_in_minutes.blank? && presence.break_length_in_minutes.to_i > standard_duration) || presence.is_acted_upon == 8
            department = person.department(presence.presence_date)
            division = person.division(presence.presence_date)
            break_more_than_normal << { :more_id => presence.id, :person_id => person.id, :person_name => person.full_name,
              :date => presence.presence_date,
              :department => (department.department_name if department),
              :division => (division.name if division),
              :work_length => presence.net_worktime.to_f,
              :break_length => presence.break_length_in_minutes.to_i,
              :status => presence.presence_status, :shift_name => schedule[:shift_name],
              :description => presence.presence_description,
              :is_acted_upon => is_acted_upon
            }
          end
        end
      end
    end
    return break_more_than_normal
  end

  def self.breaktime_less_than_normal(company_id, start_date, end_date, options={})
    presences = who_is_working(company_id, start_date, end_date, options)
    #    presences = find(:all, :conditions => ['company_id = ? AND presence_date BETWEEN ? AND ?', company_id, start_date, end_date])
    break_less_than_normal = []
    presences.each do |presence|
      person = presence.person
      schedule = person.current_schedule(presence.presence_date)
      if schedule
        standard_duration = schedule[:break_length]
        is_acted_upon = presence.is_acted_upon?(16)
        if (!presence.presence_details.first.start_working.blank? && !presence.presence_details.first.end_working.blank?) && (!presence.presence_details.last.start_working.blank? && !presence.presence_details.last.end_working.blank?)
          if (!presence.break_length_in_minutes.blank? && presence.break_length_in_minutes.to_i < standard_duration) || presence.is_acted_upon == 16
            department = person.department(presence.presence_date)
            division = person.division(presence.presence_date)
            break_less_than_normal << { :less_id => presence.id, :person_id => person.id, :person_name => person.full_name,
              :date => presence.presence_date,
              :department => (department.department_name if department),
              :division => (division.name if division),
              :work_length => presence.net_worktime.to_f,
              :break_length => presence.break_length_in_minutes.to_i,
              :status => presence.presence_status,
              :description => presence.presence_description,
              :is_acted_upon => is_acted_upon
            }
          end
        end
      end
    end
    return break_less_than_normal
  end

  # Tampilkan semua yang tidak bekerja pada periode yang dimaksud
  # Bila hari ini, list permohonan izin yang sudah disampaikan sebelumnya
  # Ditambah orang2 yang tidak memberikan permohonan izin dan tidak masuk (jam saat ini melebihi jam akhir shift dan dia masih belum masuk)
  def self.who_is_not_working(company_id, start_date, end_date, options={})
    people = people_filter(company_id, start_date, end_date, options)
    people_ids = people.map{|p| p.id}
    absences = Absence.find(:all, :conditions => ['person_id IN (?) AND absence_date BETWEEN ? AND ?', people_ids, start_date, end_date])
    presences = Presence.find(:all, :conditions => ['person_id IN (?) AND presence_date BETWEEN ? AND ?', people_ids, start_date, end_date])
    time = Time.now
    people_not_present = []
    people.each do |person|

      # Ammbil sisa jatah cuti
      remaining_quota = person.current_leave_quota_days
      leave_quota = remaining_quota >= 0 ? remaining_quota : 0
      total_start_date = Date.new(start_date.year,1,1)
      total_end_date = Date.new(end_date.year,12,-1)
      # Ammbil total ijin
      total_permision = person.absences.total_by_type(1, start_date, end_date, company_id)

      (start_date..end_date).each do |date|
        unless NationalHoliday.is_holiday?(company_id,date)
          schedule = person.current_schedule(date)
          unless schedule.blank?
            schedule_start = schedule[:schedule_start]
            presence = presences.find{|p| p.person_id == person.id && p.presence_date == date}
            department = person.department(date)
            division = person.division(date)
            if time > schedule_start && presence.blank?
              absence = absences.find{|a| a.person_id == person.id && a.absence_date == date}
              if absence
                people_not_present << { :id => absence.id, :person => person, :department => department, :division => division,
                  :date => date, :type => (absence.absence_type.absence_type_name if absence.absence_type),
                  :type_id => (absence.absence_type.type_id if absence.absence_type),
                  :reason => absence.absence_reason, :leave_quota => leave_quota, :total_permision => total_permision, :is_acted_upon => true }
              else
                people_not_present << {:person => person, :department => department, :division => division, :date => date, :leave_quota => leave_quota , :total_permision => total_permision}
              end
            elsif presence
              absence = absences.find{|a| a.person_id == person.id && a.absence_date == date}
              if absence
                people_not_present << { :id => absence.id, :person => person, :department => department, :division => division,
                  :date => date, :type => absence.absence_type.absence_type_name,
                  :type_id => (absence.absence_type.type_id if absence.absence_type),
                  :reason => absence.absence_reason, :leave_quota => leave_quota, :total_permision => total_permision,
                  :is_acted_upon => true}
              elsif presence.is_acted_upon?(32)
                people_not_present << { :id => presence.id, :person => person, :department => department, :division => division,
                  :date => date, :type => "Hadir", :reason => presence.presence_description, :is_acted_upon => presence.is_acted_upon?(32), :leave_quota => leave_quota, :total_permision => total_permision}
              end
            end
          end
        end
      end
    end
    #return people_not_present.sort_by{|p| p[:date] }
    return people_not_present
  end

  # Merupakan tindaklanjut dari HR Admin yang cingcai dengan jam istirahat yang kelebihan atau kekurangan
  # Berapa jam istirahat yang normal? person.current_employment.shift.on_day('Monday').break_length_in_minutes
  def normalize_breaktime(action)
    person = self.person
    schedule = person.current_schedule(self.presence_date)
    if schedule
      hr_setting = HrSetting.find_by_company_id(self.company_id)
      first_detail = self.presence_details.first
      last_detail = self.presence_details.last
      breaktime_in_minutes = schedule[:break_length]
      self.break_length_in_minutes = breaktime_in_minutes
      worklength = (last_detail.end_working - first_detail.start_working)/60
      self.presence_length_in_hours = (worklength - self.break_length_in_minutes).floor / 60.to_f
      self.net_worktime = ((worklength - self.break_length_in_minutes) / hr_setting.period_in_minutes ).floor * hr_setting.period_in_minutes / 60.to_f
      self.presence_description = "Disesuaikan"
      self.presence_status = "Approved"
      self.set_is_acted_upon(action)
      self.calculate_overtime
      self.save!
    else
      return false
    end
  end

  # Less Hour Actions
  # Status diganti jadi 'Dicutikan' atau 'Dianggap Izin & Lembur'
  # Harus dimasukkan ke tabel absences, dan dalam kasus 'Dianggap Izin & Lembur' juga dimasukkan ke tabel overtimes
  def deem_as_absent(absence_type)
    person = self.person
    absence = person.absences.find_by_absence_date(self.presence_date)
    absence_type_id = AbsenceType.find_by_type_id_and_company_id(absence_type, person.company_id)
    # deem_as_overtime("Dianggap Kerja Lembur")
    unless absence
      absence = person.absences.new
      absence.absence_type_id = absence_type_id.id
      absence.absence_date = self.presence_date
      absence.company_id = person.company_id
      absence.approve_absence(absence_type)
      self.set_is_acted_upon(4)
    else
      absence.absence_type_id = absence_type_id.id
      absence.approve_absence(absence_type)
      self.set_is_acted_upon(4)
    end
    self.save!
  end

  def deem_as_overtime(description=nil)
    person = self.person
    overtime = person.overtimes.find_by_overtime_date(self.presence_date)
    unless overtime
      hr_setting = HrSetting.first(:conditions => {:company_id => person.company_id})
      period_in_minutes = hr_setting.period_in_minutes
      overtime = person.overtimes.new
      overtime.overtime_date = self.presence_date
      overtime.company_id = person.company_id
      unless self.presence_details.blank?
        overtime.start_overtime = self.presence_details.first.start_working
        overtime.end_overtime = self.presence_details.last.end_working
      end
      overtime.overtime_length_in_minutes = (self.presence_length_in_hours * 60 / period_in_minutes).floor * period_in_minutes
      overtime.overtime_status = "Approved"
      overtime.overtime_description = description
      overtime.save!
    end
  end

  def in_schedule?
    person = self.person
    schedule = person.current_schedule(self.presence_date.tomorrow)
    unless schedule.blank?
      if Time.now < schedule[:schedule_start]
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def self.people_filter(company_id, start_date, end_date, options={})
    condition = ["company_id = ", company_id].join(" ")
    condition = [options[:condition], condition].join(" AND ") if options[:condition]
    the_start_date = start_date.strftime("%Y-%m-%d") if start_date
    the_end_date = end_date.strftime("%Y-%m-%d") if end_date
    if options[:department_id].to_i > 0
      employee_conds = "(department_id = #{options[:department_id]})"
      employee_conds += " AND ((employment_start BETWEEN '#{the_start_date}' AND '#{the_end_date}') OR (employment_end BETWEEN '#{the_start_date}' AND '#{the_end_date}') OR ((employment_start <= '#{the_start_date}') AND (employment_end IS NULL)) OR ((employment_start <= '#{the_start_date}') AND (employment_end >= '#{the_end_date}')))" if start_date && end_date
      employee_conds += " AND work_division_id = #{options[:division_id]}" if options[:division_id].to_i > 0
      employments = Employment.find(:all, :select => "distinct person_id", :conditions => employee_conds)
      emp_ids = employments.collect(&:person_id)
    end
    if options[:contract_type].to_i > 0
      contract_conds = "contract_type_id = #{options[:contract_type]}"
      contract_conds += " AND ((contract_start BETWEEN '#{the_start_date}' AND '#{the_end_date}') OR (contract_end BETWEEN '#{the_start_date}' AND '#{the_end_date}') OR ((contract_start <= '#{the_start_date}') AND (contract_end IS NULL)) OR ((contract_start <= '#{the_start_date}') AND (contract_end >= '#{the_end_date}')))" if start_date && end_date
      work_contracts = WorkContract.all(:select => "distinct person_id", :conditions => contract_conds)
      if emp_ids.blank?
        emp_ids = work_contracts.collect(&:person_id)
      else
        emp_ids = emp_ids & work_contracts.collect(&:person_id)
      end
    end
    condition += " AND id IN ('#{emp_ids.join("','")}')" unless emp_ids.blank?
    all_people = Person.all(:conditions => condition.to_s, :order => "firstname asc")
    return all_people
  end

  def self.who_is_not_logout(company_id, start_date, end_date, options={})
    presences = who_is_working(company_id, start_date, end_date, options)
    who_is_not_logout = []
    presences.each do |presence|
      person = presence.person
      schedule = person.current_schedule(presence.presence_date)
      department = person.department(presence.presence_date)
      division = person.division(presence.presence_date)
      position = person.current_position(presence.presence_date)
      is_acted_upon = presence.is_acted_upon?(192)
      presence.presence_details.each do |detail|
        if detail.start_working.blank? || detail.end_working.blank? || is_acted_upon
          not_logout = { :id => detail.id, :person_id => person.id, :person_name => person.full_name,
            :date => presence.presence_date,
            :department => (department.department_name if department),
            :division => (division.name if division),
            :position => (position.position_name if position),
            :shift_name => (schedule[:shift_name] if schedule),
            :start_work_session => (detail.start_working.getlocal if detail.start_working),
            :end_work_session => (detail.end_working.getlocal if detail.end_working),
            :is_acted_upon => is_acted_upon
          }
          if presence.presence_date == Date.today && schedule
            if Time.now > schedule[:schedule_end]
              who_is_not_logout << not_logout
            end
          else
            who_is_not_logout << not_logout
          end
        end
      end
    end
    return who_is_not_logout
  end

  def self.absence_statistic_chart(filter, company_id)
    statistic_chart = {}
    options = {}
    if !filter[:work_division_id].blank?
      options[:division_id] = filter[:work_division_id]
    elsif !filter[:department_id].blank?
      options[:department_id] = filter[:department_id]
    end
    if filter[:tahun].blank?
      filter[:bulan] = Date.today.strftime("%m")
      filter[:tahun] = Date.today.strftime("%Y")
    end
    options[:company_id] = company_id
    statistic_chart[:total] = []
    statistic_chart[:bulan] = []
    if filter[:bulan].blank?
      start_date = Date.parse("#{filter[:tahun]}-01-01")
      end_date = start_date.at_end_of_year
      if end_date > Date.today
        end_date = Date.today
      end
      options[:start_date] = start_date
      options[:end_date] = end_date
      all_records = PresenceReport.search_for_dashboard(options)
      absence_total = all_records.find_all{|x| x.presence_id.blank? && !x.is_holiday}
      presence_count = all_records.count{|x| !x.presence_id.blank? && !x.is_holiday}
      absence_total_count = absence_total.count
      if absence_total_count > 0 || presence_count > 0
        statistic_chart[:total] << { :name => "Hadir", :count => presence_count}
        statistic_chart[:total] << { :name => "Tidak Hadir", :count => absence_total_count}

        (1..end_date.month).each do |bulan|
          start_month_date = Date.civil(start_date.year, bulan)
          end_month_date = start_month_date.at_end_of_month
          if bulan == end_date.month
            end_month_date = end_date
          end
          absence = absence_total.find_all{|x| x.date >= start_month_date && x.date <= end_month_date}
          absence_count = absence.count

          ijin_count = absence.count{|a| a.absence_type_id == 1}
          cuti_count = absence.count{|a| a.absence_type_id == 2 || a.absence_type_id == 5 || a.absence_type_id == 6}
          sakit_count = absence.count{|a| a.absence_type_id == 3 || a.absence_type_id == 7}
          mangkir_count = absence.count{|a| a.absence_type_id == 4}
          lain_count = absence_count - (ijin_count+cuti_count+sakit_count+mangkir_count)
          statistic_chart[:bulan] << {:name => start_month_date.strftime("%b-%Y"),
            :ijin_count => ijin_count, :cuti_count => cuti_count, :sakit_count => sakit_count,
            :mangkir_count => mangkir_count, :lain_count => lain_count
          }
        end
      end
    else
      start_date = Date.parse("#{filter[:tahun]}-#{filter[:bulan]}-01")
      end_date = start_date.at_end_of_month
      options[:start_date] = start_date
      options[:end_date] = end_date
      all_records = PresenceReport.search_for_dashboard(options)
      absence = all_records.find_all{|x| x.presence_id.blank? && !x.is_holiday}
      presence_count = all_records.count{|x| !x.presence_id.blank? && !x.is_holiday}
      absence_count = absence.count
      if absence_count > 0 || presence_count > 0
        statistic_chart[:total] << { :name => "Hadir", :count => presence_count}
        statistic_chart[:total] << { :name => "Tidak Hadir", :count => absence_count}

        ijin_count = absence.find_all{|a| a.absence_type_id == 1}.count
        cuti_count = absence.find_all{|a| a.absence_type_id == 2 || a.absence_type_id == 5 || a.absence_type_id == 6}.count
        sakit_count = absence.find_all{|a| a.absence_type_id == 3 || a.absence_type_id == 7}.count
        mangkir_count = absence.find_all{|a| a.absence_type_id == 4}.count
        lain_count = absence_count - (ijin_count+cuti_count+sakit_count+mangkir_count)
        statistic_chart[:bulan] << {:name => start_date.strftime("%b-%Y"),
          :ijin_count => ijin_count, :cuti_count => cuti_count, :sakit_count => sakit_count,
          :mangkir_count => mangkir_count, :lain_count => lain_count
        }
      end
    end
    return statistic_chart
  end

  def self.minutes_to_hour_text(minutesfixnum)
    hours = (minutesfixnum / 60).to_i
    minutes = (minutesfixnum % 60).to_i
    hours_string = hours.to_s
    minutes_string = minutes.to_s
    if hours > 0
      return "#{hours_string} Jam #{minutes_string} Menit"
    else
      return "#{minutes_string} Menit"
    end
  end

  def self.hours_to_hour_text(hoursnum)
    hours = (hoursnum / 1).to_i
    minutes = ((hoursnum % 1) * 60)
    hours_string = hours.to_s
    minutes_string = sprintf("%.2f", minutes)
    if hours > 0
      return "#{hours_string} Jam #{minutes_string} Menit"
    else
      return "#{minutes_string} Menit"
    end
  end

  def self.minutes_to_hour(minutesfixnum)
    hours = (minutesfixnum / 60).to_i
    minutes = (minutesfixnum % 60).to_i
    if hours < 10
      hours_string = "0#{hours}"
    else
      hours_string = hours.to_s
    end
    if minutes < 10
      minutes_string = "0#{minutes}"
    else
      minutes_string = minutes.to_s
    end
    return "#{hours_string}:#{minutes_string}"
  end

  def self.hoursnum_to_hour(hoursnum)
    hours = (hoursnum / 1).to_i
    minutes = ((hoursnum % 1) * 60).to_i
    if hours < 10
      hours_string = "0#{hours}"
    else
      hours_string = hours.to_s
    end
    if minutes < 10
      minutes_string = "0#{minutes}"
    else
      minutes_string = minutes.to_s
    end
    return "#{hours_string}:#{minutes_string}"
  end

  def self.get_item_for_monthly_absence(row, company_id)
    absence_type = AbsenceType.all(:conditions => ['company_id = ?', company_id])
    masuk = ""
    keluar = ""
    lama_kerja = ""
    lembur = ""
    keterangan = ""
    if !row.absence_id.blank?
      lama_kerja = row.absence_code
      lembur = "-"
      a = absence_type.find{|at| at.type_id == row.absence_type_id}
      keterangan = a.blank? ? " " : a.absence_type_name
    elsif !row.presence_id.blank?
      p = Presence.find(row.presence_id)
      details = p.presence_details.all(:conditions => "start_working is not null and end_working is not null", :order => :start_working)
      masuk =  details.blank? ? " " : details.first.start_working.getlocal.strftime("%H:%M")
      keluar = details.blank? ? " " : details.last.end_working.getlocal.strftime("%H:%M")
      lama_kerja = Presence.hours_to_hour_text(row.work_duration) if row.work_duration
      lembur = Presence.minutes_to_hour_text(row.overtime_duration * 60) if row.overtime_duration
      keterangan = ""
    else
      lama_kerja = row.absence_code
      lembur = " - "
      if row.absence_code == "L"
        keterangan = "Libur"
      else
        keterangan = "Tidak Masuk Kerja"
      end
    end
    return {:lama_kerja => lama_kerja, :lembur => lembur, :keterangan => keterangan,:masuk => masuk, :keluar => keluar}
  end

  def self.get_year(params, month)
    if params[:year]
      year = Date.civil(Date.strptime(params[:year], '%d/%m/%Y').year.to_i)
    else
      year = Date.today
    end
    date_start = Time.mktime(year.year,month).to_date
    return  {:date_start=>date_start, :year => year}
  end

  def self.is_presence_ids_belongs_to_current_company?(presence_ids, current_company_id)
    has_access = true
    presences = Presence.find(:all, :conditions => { :id => presence_ids, :company_id => current_company_id } )
    if presences.blank?
      has_access = false
    end
    has_access
  end
  
  def self.check_data(company_id,holding_id)
    check = self.find_by_company_id(company_id)
    if check.blank?
      puts "     Running Presence"
      EmployeeShift.find(:all,:conditions=>["company_id = ? and is_active = ?",company_id,1]).each do |d|
        d.shift_from.to_date.upto((Date.today-1.day)) do |day|
            case day.to_time.strftime("%u").to_i
              when 1 # monday_time_id
                worktime = d.shift.monday_time_id
              when 2 # tuesday
                worktime = d.shift.tuesday_time_id
              when 3 # wednesday
                worktime = d.shift.wednesday_time_id
              when 4 # thursday
                worktime = d.shift.thursday_time_id
              when 5 # friday
                worktime = d.shift.friday_time_id
              when 6 # saturday
                worktime = d.shift.saturday_time_id
              when 7 # sunday
                worktime = d.shift.sunday_time_id
              else
            end
            work_time = WorkTime.find_by_id(worktime)
            unless work_time.length_in_hours.to_i == 0
              start_date = "#{day.strftime("%Y-%m-%d")}#{work_time.start_time.strftime(" %H:%M:%S")}"
              end_shift = (d.shift.shift_code == "Shift3")? day+1.day : day
              end_date = "#{end_shift.strftime("%Y-%m-%d")}#{work_time.end_time.strftime(" %H:%M:%S")}"
              second_hours = ((end_date.to_time - start_date.to_time)/60)/60
              worksession = (second_hours*60).ceil

              emply = Employment.find_by_person_id(d.person_id)
              data = self.new()
              data.company_id = company_id
              data.person_id = d.person_id
              data.presence_date = day.strftime("%Y-%m-%d")
              data.presence_length_in_hours =  second_hours.round(4)
              data.paid_hours =  second_hours.round(4)
              data.presence_status = "Approved"
              # data.presence_description =
              data.is_acted_upon = 256
              # data.moved_worktime_in_hours =
              data.net_worktime = second_hours.round(2)
              if data.save
                data_detail = PresenceDetail.new
                data_detail.presence_id = data.id
                data_detail.start_working = start_date
                data_detail.end_working = end_date
                data_detail.work_session_length_in_minutes = worksession
                data_detail.save!
                # data_report = PresenceReport.new
                # data_report.presence_id =  data.id
                # # data_report.absence_id = 
                # data_report.company_id = company_id
                # data_report.department_id = emply.department_id
                # data_report.division_id = emply.work_division_id
                # data_report.person_id = d.person_id
                # data_report.employee_id = emply.id
                # data_report.date = day.to_date
                # # data_report.is_holiday = 
                # data_report.full_name = "#{d.person.firstname} #{d.person.lastname}"
                # data_report.department_name = emply.department.department_name
                # data_report.division_name = emply.division.name
                # # data_report.work_duration = 
                # # data_report.overtime_duration = 
                # data_report.shift_code = "d.shift.shift_code"
                # data_report.save!
              end
            end
        end
      end
    end
  end

  private
  def update_presence_report
    PresenceReport.update_report(self)
  end

  def update_recurring_sick
    person = self.person
    recurring_sick = person.person_recurring_sicks.last(:conditions => ['first_time_sick_date > ? AND first_presence_date_after_sick is null', self.presence_date])
    unless recurring_sick.blank?
      recurring_sick.update_attributes({:first_presence_date_after_sick => self.presence_date})
    end
  end

  def clear_overtime_and_report
    overtimes = Overtime.all(:conditions => ['person_id = ? AND overtime_date = ?', self.person_id, self.presence_date])
    PresenceReport.connection.execute "UPDATE presence_reports SET `presence_id` = null, `work_duration` = null, `special_overtime` = null, `overtime_duration` = null WHERE `person_id` = #{self.person_id} AND `date` = '#{self.presence_date.to_s(:db)}'"
    overtimes.each do |overtime|
      overtime.destroy
    end unless overtimes.blank?
  end

end

# NOTE
=begin
  Note for is_acted_upon I move this field from PresenceDetail to Presence
  1   = Late
  2   = More Hour
  4   = Less Hour
  8   = More Rest
  16  = Less Rest
  32  = Not Work
  64  = Not Logout
  128 = Not Login
  256 = Absen manual
=end
