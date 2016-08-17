# == Schema Information
#
# Table name: presence_details
#
#  id                             :integer(4)      not null, primary key
#  presence_id                    :integer(4)
#  start_working                  :datetime
#  end_working                    :datetime
#  lateness_in_minutes            :integer(4)
#  lateness_reason                :string(255)
#  created_at                     :datetime
#  updated_at                     :datetime
#  work_session_length_in_minutes :integer(4)
#

class PresenceDetail < ActiveRecord::Base
  belongs_to :presence

  #lateness_in_minutes selalu kelipatan 'period_in_minutes' menit (pembulatan ke atas), selalu NULL dulu sampai di tindaklanjutin oleh HR admin.
  # def ini adalah hasil tindaklanjut 'approval' dari admin bahwa yang bersangkutan memang terlambat
  # Bila dianggap terlambat maka presence_length_in_hours dikurangi
  # pada saat ini juga diisi lateness_reason
  def approve_lateness(reason = nil)
    presence = self.presence
    person = presence.person
    hr_setting = HrSetting.first(:conditions => {:company_id => person.company_id})
    period_in_minutes = hr_setting.period_in_minutes.to_f
    tolerance = hr_setting.lateness_tolerance_in_minutes
    sched_time = person.current_schedule(presence.presence_date)
    start_schedule = sched_time[:schedule_start] + tolerance.minutes
    if self.start_working > start_schedule
      self.lateness_in_minutes = ((self.start_working - start_schedule)/(60*period_in_minutes)).ceil * period_in_minutes
      presence.set_is_acted_upon(1)
      self.lateness_reason = reason
      self.save!
      return true
    end
  end

  # Anggap tidak terlambat, lateness_in_minutes jadi 0
  # Jangan lupa is_acted_upon jadi true
  def override_lateness(lateness_in_minutes = 0, reason = nil)
    presence = self.presence
    if lateness_in_minutes >= 0
      self.lateness_in_minutes = lateness_in_minutes
      presence.set_is_acted_upon(1)
      self.calculate_time
      if lateness_in_minutes == 0
        self.lateness_reason = "Override menjadi tidak terlambat"
      else
        self.lateness_reason = "Override menjadi terlambat #{lateness_in_minutes} Menit"
      end
    else
      self.approve_lateness(reason)
    end
    presence.calculate_work_time
    self.save!
  end

  # Insert ke tabel overtimes langsung statusnya 'Approved'
  # overtime_length_in_minutes kelipatan period_in_minutes
  # Bila supir ada itungannya sendiri
  def approve_overtime(description = nil, driver = false)
    person = self.presence.person
    overtime = person.overtimes.find(:first, :conditions => ['start_overtime = ?', self.start_working])
    unless overtime
      hr_setting = HrSetting.first(:conditions => {:company_id => person.company_id})
      overtime = person.overtimes.new
      time_in_minutes = self.work_session_length_in_minutes
      period_in_minutes = hr_setting.period_in_minutes
      overtime.start_overtime = self.start_working
      overtime.end_overtime = self.end_working
      overtime.overtime_status = "Approved"
      overtime.overtime_description = description
      overtime.overtime_length_in_minutes = (time_in_minutes/period_in_minutes).floor * period_in_minutes
      overtime.company_id = person.company_id
      overtime.save!
    end
    if driver
    end
  end


  # Dianggap kerja di hari lain
  def move_worktime_to_another_day(date, duration=0)
    person = self.presence.person
    presence = person.presences.find_by_presence_date(date)
    unless presence
      presence = person.presences.new
      presence.presence_date = date
      presence.company_id = person.company_id
    end
    presence.presence_length_in_hours += (self.end_working - self.start_working)/3600.to_f
    presence.paid_hours = presence.presence_length_in_hours
    self.save!
  end

  def calculate_time(rest_length=nil)
    if self.end_working
      # work_session_length = ((self.end_working - self.start_working)/60).floor
      presence = self.presence
      if presence.is_acted_upon?(1)
        person = presence.person
        schedule = person.current_schedule(presence.presence_date)
        work_session_length = ((self.end_working - (schedule[:schedule_start] + self.lateness_in_minutes.minutes))/60)
      else
        work_session_length = ((self.end_working - self.start_working)/60)
      end
      work_session_length -= rest_length.to_i
      if work_session_length > 0
        self.update_attributes(:work_session_length_in_minutes => work_session_length)
      end
    end
  end

end


