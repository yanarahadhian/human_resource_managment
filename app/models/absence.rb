# == Schema Information
#
# Table name: absences
#
#  id              :integer(4)      not null, primary key
#  company_id      :integer(4)
#  person_id       :integer(4)
#  absence_date    :date
#  absence_type_id :integer(4)
#  absence_reason  :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Absence < ActiveRecord::Base
  belongs_to :person
  belongs_to :absence_type
  after_save :update_presence_report
  after_save :update_recurring_sick
  after_save :delete_presence
  before_create :mark_me_if_i_cut_employee_leave_quota
  after_update :unmark_me_as_cut_employee_leave_quota_when_it_restored

  def self.count_days_are_not_covered_by_leaves_quota(absences)
    days_to_salary_cut = 0
    unless absences.blank?
      absences.each do |absence|
        days_to_salary_cut  += 1 unless absence.is_cut_employee_leave_quota
      end
    end
    days_to_salary_cut
  end

  def self.count_days_are_cut_employee_leave_quota(absences)
    days = 0
    unless absences.blank?
      absences.each do |absence|
        days  += 1 if absence.is_cut_employee_leave_quota
      end
    end
    days
  end

  def is_salary_paid?
    self.absence_type.is_salary_paid
  end

  def count_on_salary_cut?
    count_me = true
    if self.is_cut_employee_leave_quota or self.absence_type.is_salary_paid
      count_me = false 
    end
    count_me
  end

  def unmark_me_as_cut_employee_leave_quota_when_it_restored
    #Query ulang absence_type karena cache
    absence_type = AbsenceType.find(self.absence_type_id)
    if !absence_type.blank? and !absence_type.count_as_leave and self.is_cut_employee_leave_quota
      self.is_cut_employee_leave_quota = false
      self.save
    end
  end

  def self.sequential_absences(company_id, type_id)
    people = Person.all(:conditions => ["company_id = ?", company_id])
    absence_type = AbsenceType.find_by_type_id_and_company_id( type_id, company_id)
    total = 0
    people.each do |person|
      date = Date.yesterday
      absence = person.absences.last(:conditions => ["absence_type_id = ? AND absence_date = ?", absence_type.id ,date])
      if absence
        date = date.yesterday
        schedule = person.current_schedule(date)
        while schedule.blank? || schedule[:schedule_length] == 0
          date = date.yesterday
        end
        absence = person.absences.last(:conditions => ["absence_type_id = ? AND absence_date = ?", absence_type.id ,date])
        total += 1 if absence
      end
    end
    return total
  end

  # Kalo quota udah lebih, cuti otomatis dianggap izin
  # bila cuti melahirkan, maka insert row 3 bulaneun
  def approve_absence(type_id, date = Date.today)
    person = self.person
    absence_type = AbsenceType.find_by_type_id_and_company_id( type_id, person.company_id)
    if absence_type.type_id == 6
      date_end = date + 89.days
      while (date < date_end)
        absence = person.absences.new
        absence.absence_type = absence_type
        absence.company_id = person.company_id
        absence.absence_date = date
        absence.absence_reason = "Cuti Melahirkan"
        absence.save!
        date = date.tomorrow
      end
    end
    if absence_type.type_id == 2
      if person.employee_leaves.find_by_leave_date(self.absence_date).nil?
        leave = person.employee_leaves.new
        leave.company_id = person.company_id
        leave.leave_date = self.absence_date
        leave.leave_description = "Dicutikan"
        leave.leave_status = "Approved"
        leave.save!
      end
      self.absence_reason = "Dicutikan"
      self.save!
    else
      self.absence_type = absence_type
      self.absence_reason = "Dianggap Izin"
      leave = person.employee_leaves.find_by_leave_date( self.absence_date)
      if leave
        leave.destroy!
      end
      self.save!
    end
  end

  def make_absent(absence_type_id, absent_date = Date.today, description = nil)
    person = self.person
    #FIXME: Note by Feby: Method ini perlu di review karena method ini dipanggil oleh new Object Absence tapi ada pencarian object absen lagi
    absence = person.absences.find_by_absence_date(absent_date)
    absence_type = AbsenceType.find(absence_type_id)
    # Make employee leaves
    if absence_type.count_as_leave
      #NOTE by FEBY: Method ini perlu diperbaiki untuk kondisi update 
      leave = person.employee_leaves.new
      leave.leave_date = absent_date
      leave.leave_status = (absent_date <= Date.today) ? "Approved" : "Pending"
      leave.company_id = person.company_id
      leave.leave_description = description
      leave.save
    end
    unless absence
      self.absence_type_id = absence_type_id
      self.absence_reason = description
      self.absence_date = absent_date
      self.company_id = person.company_id
      if self.save!
        return self
      end
    else
      leave = person.employee_leaves.find_by_leave_date(absent_date)
      unless leave.blank?
        leave.destroy if absence.absence_type && absence.absence_type.count_as_leave && !absence_type.count_as_leave
      end
      absence.absence_type_id = absence_type_id
      absence.absence_reason = description
      if absence.save
        return absence
      end
    end
  end

  def self.clear_other_data
    company_ids = User.all.map(&:company_id).uniq
    company_ids.each do |company_id|
      people = Person.all(:conditions => ['company_id = ?', company_id])
      updates = []
      people.each do |person|
        absence_dates = person.absences.map(&:absence_date)
        unless absence_dates.blank?
          presences = person.presences.all(:conditions => ['presence_date IN (?)', absence_dates ])
          overtimes = person.overtimes.all(:conditions => ['overtime_date IN (?)', absence_dates ])
          presences.each do |p|
            p.destroy
          end unless presences.blank?
          overtimes.each do |o|
            o.destroy
          end unless overtimes.blank?
          absence_dates.each do |date|
            updates.push "UPDATE presence_reports SET `presence_id` = null, `work_duration` = null, `special_overtime` = null, `overtime_duration` = null WHERE `person_id` = #{person.id} AND `date` = '#{date.to_s(:db)}'"
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
  end

  def self.save_absen(params,company_id)
    person = Person.find_by_full_name(params['name'])
    if person.nil?
      return false
    else
      x = params['absence_length'].to_i
      i = 0
      if x > 0
        x.times do
          absence = Absence.new(params['absence'])
          absence.company_id = company_id
          absence.person_id =  person.id
          if x > 1
            absence.absence_date = absence.absence_date + i
          end
          puts '===================================================='
          puts params['absence']
          if params['absence']['absence_reason'] == "Cuti"
            leave = EmployeeLeave.leaves_save(company_id, person.id , absence.absence_date , params['leave_description'])
            leave.save
            absence.save
          else
            absence.save
          end
          i = i + 1
        end
      end
    end
  end

  private
  def update_presence_report
    PresenceReport.update_report(self, 1)
  end

  def update_recurring_sick
    absence_type = self.absence_type.type_id
    if [4,7].include?(absence_type)
      person = self.person
      recurring_sick = person.person_recurring_sicks.last(:conditions => ['first_time_sick_date > ?', self.absence_date])
      if recurring_sick.blank?
        person.person_recurring_sicks.create(:first_time_sick_date => self.absence_date)
      else
        unless recurring_sick.first_presence_date_after_sick.blank?
          person.person_recurring_sicks.create(:first_time_sick_date => self.absence_date)
        end
      end
    end
  end

  def delete_presence
    person = self.person
    presence = person.presences.find_by_presence_date(self.absence_date)
    overtimes = person.overtimes.all(:conditions => ['overtime_date = ?',self.absence_date])
    presence.destroy unless presence.blank?
    overtimes.each do |overtime|
      overtime.destroy
    end unless overtimes.blank?
  end

  def mark_me_if_i_cut_employee_leave_quota     
    if self.absence_type and self.absence_type.count_as_leave
      self.is_cut_employee_leave_quota = true if self.person.current_leave_quota_days > 0
    end
  end

end


