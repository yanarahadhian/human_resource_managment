# == Schema Information
#
# Table name: employee_shifts
#
#  id            :integer(4)      not null, primary key
#  person_id     :integer(4)
#  shift_id      :integer(4)
#  shift_from    :date
#  shift_to      :date
#  created_at    :datetime
#  updated_at    :datetime
#  work_group_id :integer(4)
#  company_id    :integer(4)
#

class EmployeeShift < ActiveRecord::Base
  belongs_to :person
  belongs_to :shift
  belongs_to :division
  belongs_to :work_group
  named_scope :by_company, lambda {|val| {:conditions => "company_id = #{val}"}}
  validates_presence_of :person_id, :message => "Nama karyawan tidak boleh kosong"
  validates_presence_of :shift_from, :message => "Tanggal mulai jadwal kerja tidak boleh kosong"
  validates_presence_of :shift_to, :message => "Tanggal akhir jadwal kerja tidak boleh kosong"
  after_save :update_compulsory_overtime

  attr_protected :company_id

  after_save :set_schedule_on_hr_setting
  after_destroy :unset_schedule_on_hr_setting
  def set_schedule_on_hr_setting
    hr_setting = HrSetting.find_by_company_id(self.company_id)
    hr_setting.update_attributes(:schedule_is_set => true) if !hr_setting.blank? && !hr_setting.schedule_is_set
  end

  def unset_schedule_on_hr_setting
    schedule = EmployeeShift.find(:first, :select => 'id', :conditions=> "company_id = #{self.company_id}")
    if schedule.blank?
      hr_setting = HrSetting.find_by_company_id(self.company_id)
      hr_setting.update_attributes(:schedule_is_set => false) 
    end
  end

  def self.search_filter(f,company_id)
    cond = get_str_kondisi(f,company_id)
    return cond
  end

  def self.get_str_kondisi(f,company_id)
    cond = "employee_shifts.company_id = #{company_id}"
    unless f[:nama_shift].blank?
      shift = Shift.find(f[:nama_shift].to_i)
      unless shift.blank?
        #temp_id_s = shift_id.map{|x| x.id}.join(",")
        cond << " AND employee_shifts.shift_id = #{shift.id} "
      else
        cond << " AND employee_shifts.shift_id = 0 "
      end
    end
    unless f[:nama_karyawan].blank?
      person = Person.find(:all, :conditions => ["firstname like ? or lastname like ? or CONCAT(TRIM(firstname),' ',TRIM(lastname)) like ? and company_id = ?", "%#{f[:nama_karyawan]}%", "%#{f[:nama_karyawan]}%", "%#{f[:nama_karyawan]}%", company_id])
      unless person.blank?
        temp_pid = person.map{|x| x.id}.join(",")
        cond << " AND employee_shifts.person_id in (#{temp_pid})"
      else
        cond << " AND employee_shifts.person_id = 0 "
      end
    end
    unless f[:nama_group].blank? || f[:nama_group].to_i == 0
      work_group = WorkGroup.find(f[:nama_group])
      unless work_group.blank?
        #temp_wg_id = work_group_id.map{|x| x.id}.join(",")
        cond << " AND employee_shifts.work_group_id = #{work_group.id}"
      else
        cond << " AND employee_shifts.work_group_id = 0 "
      end
    end
    unless f[:periode_start].blank? and f[:periode_end].blank?
      cond <<  " AND ( employee_shifts.shift_from BETWEEN '#{f[:periode_start]}' AND '#{f[:periode_end]}'"
      cond << " OR employee_shifts.shift_to BETWEEN '#{f[:periode_start]}' AND '#{f[:periode_end]}'"
      cond << " OR '#{f[:periode_start]}' BETWEEN employee_shifts.shift_from AND employee_shifts.shift_to OR '#{f[:periode_end]}' BETWEEN employee_shifts.shift_from AND employee_shifts.shift_to )"
    end
    unless f[:nama_bagian].blank? || f[:nama_bagian].to_i == 0
      division = Division.find(f[:nama_bagian])
      person = division.personel
      unless division.blank?
        temp_id = person.map{|x| x.id}.join(",")
        cond << " AND employee_shifts.person_id in (#{temp_id})"
      else
        cond << " AND employee_shifts.person_id = 0"
      end
    end
    return cond
  end

  def update_employee_work_group (emp_id)
    emps = EmployeeShift.all(:conditions => ['person_id = ?', emp_id])
    work_group_id = Employment.first(:conditions =>['person_id = ?', emp_id], :select => "work_group_id")
    emps.each do |e|
      e.update_attributes(:work_group_id => work_group_id)
    end
  end

  def self.insert_employee_shift(employee_shift,params)
    days = (params[:shift_from]..params[:shift_to]).to_a
    active_employee_shift = find(:last, :conditions => ['person_id = ? AND is_active = true', params[:person_id]])
    employee_shifts = find(:all, :conditions => ['person_id = ? AND (shift_from IN (?) OR shift_to IN (?))', params[:person_id], days, days])
    if employee_shift.blank?
      if active_employee_shift && active_employee_shift.shift_to == params[:shift_to] && active_employee_shift.shift_from == params[:shift_from]
        active_employee_shift.update_attributes(:shift_id => params[:shift_id])
      else
        schedule = EmployeeShift.new(params)
        schedule.company_id = params[:company_id]
        if schedule.save
          if active_employee_shift
            # Jika ada active_employee_shift update is_active menjadi nil
            active_employee_shift.update_attributes(:is_active => nil)
          end
          # bersihkan scheduling yang beririsan / subset scheduling baru
          # Update tanggal shift_from/shift_to jika beririsan
          # Jika scheduling lama merupakan subset dari jadwal baru, hapus scheduling lama.
          employee_shifts.each do |es|
            es.update_attributes(:is_active => nil) if es.is_active
            if days.include?(es.shift_from) && days.include?(es.shift_to)
              es.destroy
            else
              es.shift_to = params[:shift_from].yesterday if days.include?(es.shift_to)
              es.shift_from = params[:shift_to].tomorrow if days.include?(es.shift_from)
              es.company_id = params[:company_id]
              es.save
            end
          end unless employee_shifts.blank?
          return true
        else
          return false
        end
      end
    elsif employee_shift != active_employee_shift
      if active_employee_shift
        active_employee_shift.update_attributes(:is_active => nil)
      end
      # bersihkan scheduling yang beririsan / subset scheduling baru
      # Update tanggal shift_from/shift_to jika beririsan
      # Jika scheduling lama merupakan subset dari jadwal baru, hapus scheduling lama.
      employee_shifts.each do |es|
        es.update_attributes(:is_active => nil) if es.is_active
        if days.include?(es.shift_from) && days.include?(es.shift_to)
          es.destroy
        else
          es.shift_to = params[:shift_from].yesterday if days.include?(es.shift_to)
          es.shift_from = params[:shift_to].tomorrow if days.include?(es.shift_from)
          es.company_id = params[:company_id]
          es.save
        end
      end unless employee_shifts.blank?
      if employee_shift.update_attributes(:is_active => true)
        return true
      else
        return false
      end
    else
      employee_shift.update_attributes(:shift_id => params[:shift_id])
      employee_shift.update_attributes(:is_active => true)
      return true
    end
  end

  def self.check_data(current_company_id,holding_id)
    check = self.find(:first,:conditions => ["company_id = ?",current_company_id])
    if check.blank?
      puts "     Running Shift employee"
      # date = Date.today - 2.month
      now = "#{Date.today.year}-#{Date.today.mon}-1"
      lastmonth = Date.today + 1.month
      lastmonthday = Date.civil(lastmonth.year,lastmonth.mon,-1)
      start_date = Date.parse now
      end_date = lastmonthday
      employee = Person.find(:all , :conditions => ["company_id = ? and holding_company_id = ?", current_company_id,holding_id])
      shift = Array.new
      Shift.find(:all,:conditions => ["company_id = ?",current_company_id]).each {|key,value| shift << key.id}
      employee.each do |d|
        data = self.new()
        data.person_id = d.id
        data.shift_id = shift.rand
        data.shift_from = "#{d.employments[0].employment_start}"
        data.shift_to ="#{end_date}"
        data.work_group_id = d.employments[0].work_group_id
        data.company_id = current_company_id
        data.is_active = true
        data.save!
        # require "pp"
        # pp data.errors.full_messages
      end
    end
  end

  private
  def update_compulsory_overtime
    days = (self.shift_from..self.shift_to).to_a
    person = self.person
    presences = person.presences.all(:conditions => {:presence_date => days})
    presences.each do |presence|
      presence.calculate_overtime
    end unless presences.blank?
  end

end

