class Person < ActiveRecord::Base
  has_many :overtime_datas, :dependent => :destroy
  has_many :awards, :order => 'award_date DESC', :dependent => :destroy
  has_many :educations, :order => 'entry_year DESC', :dependent => :destroy
  has_many :addresses, :as => :owner, :order => 'created_at DESC', :dependent => :destroy
  accepts_nested_attributes_for :addresses, :allow_destroy => true
  has_many :experiences, :dependent => :destroy
  has_many :families, :order => 'created_at DESC'
  has_many :employments, :dependent => :destroy
  accepts_nested_attributes_for :employments
  has_many :employee_shifts, :dependent => :destroy
  has_many :trainings, :dependent => :destroy
  has_many :violations, :dependent => :destroy
  has_many :person_in_charge_for, :foreign_key => "person_in_charge_id", :class_name => "Violation"
  has_many :accidents, :dependent => :destroy
  has_many :employment_histories
  has_many :people_tax_statuses, :dependent => :destroy
  belongs_to :tax_status
  has_many :work_contracts, :dependent => :destroy
  accepts_nested_attributes_for :work_contracts
  has_many :honors, :dependent => :destroy#, :foreign_key => :person_id
  belongs_to :user, :dependent => :destroy
  has_one :salary_master_data, :dependent => :destroy
  has_many :attendance_reports, :dependent => :destroy

  after_save :set_employee_on_hr_setting
  after_destroy :unset_employee_on_hr_setting
  
  def set_employee_on_hr_setting
    hr_setting = HrSetting.find_by_company_id(self.company_id)
    hr_setting.update_attributes(:employee_is_set => true) if !hr_setting.blank? && !hr_setting.employee_is_set
    FingerprintDevice.count_and_update_no_schedule_on_hr_setting(self.company_id)
  end

  def unset_employee_on_hr_setting
    person = Person.find(:first, :select => 'id', :conditions=> "company_id = #{self.company_id}")
    if person.blank?
      hr_setting = HrSetting.find_by_company_id(self.company_id)
      hr_setting.update_attributes(:employee_is_set => false)      
    end
    FingerprintDevice.count_and_update_no_schedule_on_hr_setting(self.company_id)
  end

  def self.format_date_for_ree(date)
    new_date = date.to_s
    if new_date.include?("/")
      date_arr = new_date.split("/")
      new_date = date_arr.reverse.join("-")
    end
    new_date
  end

  has_many :person_recurring_sicks, :dependent => :destroy do
    def total_sickniesses_by_month(x, begin_date)
      conditions = "((`first_presence_date_after_sick` - INTERVAL #{x} MONTH) >= first_time_sick_date) AND ('#{begin_date}' < (`first_presence_date_after_sick` + INTERVAL 3 MONTH)) AND ('#{begin_date}' >= `first_presence_date_after_sick`)"
      find(:last, :conditions => conditions)
    end
  end

  has_many :absences, :dependent => :destroy do

    def total_unpaid_premium(company_id, start_date, end_date)
      absence_types = AbsenceType.find(:all, :conditions => ['company_id = ? AND allowance_are_paid = ?', company_id, false]).map(&:id)
      if absence_types
        count(:conditions => ['absence_type_id IN (?) AND absence_date BETWEEN ? AND ?', absence_types, start_date, end_date])
      end
    end

    def total_unpaid(company_id, start_date, end_date)
      unpaid_types = AbsenceType.find(:all, :conditions => ['company_id = ? AND is_salary_paid = ? AND count_as_leave = ?', company_id, false, false]).map(&:id)
      leave_types = AbsenceType.find(:all, :conditions => ['company_id = ? AND is_salary_paid = ? AND count_as_leave = ?', company_id, true, true]).map(&:id)
      person = proxy_owner      
      quota = person.leave_quota(start_date)
      quota_unpaid_date = quota.out_of_quota unless quota.blank?
      rv = 0
      remaining_quota = person.leaves_quotas.remaining_quota
      total_leaves = count(:conditions => ['absence_type_id IN (?) AND absence_date BETWEEN ? AND ?', leave_types, start_date, end_date])
      # Kalau jatah cuti habis potong gaji
      if quota && remaining_quota > 0 
        new_remaining_quota = remaining_quota - total_leaves
        if new_remaining_quota < 0
          rv -= new_remaining_quota
        end
      else
        rv += total_leaves
      end
      if unpaid_types
        rv += count(:conditions => ['absence_type_id IN (?) AND absence_date BETWEEN ? AND ?', unpaid_types, start_date, end_date])
      end
      rv
    end

    def list_total_unpaid(company_id, start_date, end_date)
      unpaid_types = AbsenceType.find(:all, :conditions => ['company_id = ? AND is_salary_paid = ? AND count_as_leave = ?', company_id, false, false]).map(&:id)
      leave_types = AbsenceType.find(:all, :conditions => ['company_id = ? AND is_salary_paid = ? AND count_as_leave = ?', company_id, true, true]).map(&:id)
      person = proxy_owner
      quota = person.leave_quota(start_date)
      quota_unpaid_date = quota.out_of_quota unless quota.blank?
      rv = 0
      rv_list = []
      remaining_quota = person.leaves_quotas.remaining_quota
      total_leaves = count(:conditions => ['absence_type_id IN (?) AND absence_date BETWEEN ? AND ?', leave_types, start_date, end_date])
      # Kalau jatah cuti habis potong gaji
      if quota && remaining_quota > 0 
        new_remaining_quota = remaining_quota - total_leaves
        if new_remaining_quota < 0
          rv -= new_remaining_quota
        end
      else
        rv += total_leaves
      end
      if total_leaves != rv
        except_list = all(:select => :id, :limit => rv, :conditions => ['absence_type_id IN (?) AND absence_date BETWEEN ? AND ?', leave_types, start_date, end_date], :order => 'absence_date ASC')
        if except_list.blank?
          rv_list += Absence.find(:all, :conditions => ["person_id = ? AND absence_type_id IN (?) AND absence_date BETWEEN ? AND ?", person.id, leave_types, start_date, end_date])
        else
          rv_list += all(:conditions => ['id NOT IN (?) AND absence_type_id IN (?) AND absence_date BETWEEN ? AND ?', except_list, leave_types, start_date, end_date], :order => 'absence_date ASC')
        end
      else
        rv_list += all(:conditions => ['absence_type_id IN (?) AND absence_date BETWEEN ? AND ?', leave_types, start_date, end_date], :order => 'absence_date ASC')
      end
      if unpaid_types
        rv_list += all(:conditions => ['absence_type_id IN (?) AND absence_date BETWEEN ? AND ?', unpaid_types, start_date, end_date])
      end
      rv_list
    end

    # return [{:description => ..., :date => ...}, {...}]
    def list_by_type(type_ids, from, to, company_id)
      absence_types = AbsenceType.find(:all, :conditions => ['type_id IN (?) AND company_id = ?', type_ids, company_id]).map(&:id)
      list_absences = find(:all, :conditions => ['absence_type_id IN (?) AND absence_date BETWEEN ? AND ?', absence_types, from, to])
      list_by_type = []
      list_absences.each do |absence|
        list_by_type << {:description => absence.absence_reason, :date => absence.absence_date, :type_name => absence.absence_type.absence_type_name}
      end
      return list_by_type
    end

    def total_by_type(absence_types, from, to, company_id)
      list_by_type(absence_types, from, to, company_id).count
    end

    def get_absent_by_periode(type_id, pend_date, distance)
      start_date = (pend_date-distance.months).at_beginning_of_month
      end_date = start_date + 3.months
      between = "absences.absence_date >= '#{start_date.strftime("%Y-%m-%d")}' AND absences.absence_date<'#{end_date.strftime("%Y-%m-%d")}'"
      kond = "absence_types.type_id in (#{type_id.join(",")}) AND #{between}"
      absent = find(:all, :include=>[:absence_type], :conditions => kond , :order => "absences.absence_date DESC")
      return absent
    end

    #Kapan saja tidak hadir secara sequential (Untuk kebutuhan my absence page)
    def sequential_absences(company_id, type_id, start_date, end_date=Date.today)
      absence_type = AbsenceType.find_by_type_id_and_company_id( type_id, company_id)
      absence = find(:first, :conditions => ['absence_type_id = ? AND absence_date BETWEEN ? AND ?', absence_type.id, start_date, end_date], :order => "absence_date ASC")
      sequential_absences = []
      if absence
        date = absence.absence_date
        person = absence.person
        while date < end_date
          total = 0
          absence = find(:first, :conditions => ['absence_type_id = ? And absence_date = ?', absence_type.id, date])
          first_date = absence.absence_date if absence
          description = absence.absence_reason if absence
          while !absence.blank?
            date = date.tomorrow
            absence = find(:first, :conditions => ['absence_type_id = ? And absence_date = ?', absence_type.id, date])
            while person.current_schedule(date).blank?
              date = date.tomorrow
              absence = find(:first, :conditions => ['absence_type_id = ? And absence_date = ?', absence_type.id, date])
            end unless absence.blank?
            total += 1
          end
          if total > 0
            sequential_absences << {:total_days => total, :from_date => first_date, :to_date => date.yesterday, :description => description}
          end
          date = date.tomorrow
        end
      end
      return sequential_absences
    end

    # sequential itu berturut2.
    # return apakah dia pernah dalam periode yg dimaksud absen berturut2 sebanyak total_sequential (tru atau false)
    def sequential_exists?(company_id, month, year, type_id, total_sequential)
      ps = PayrollSetting.find_by_company_id(company_id)
      unless ps.cut_off_date.blank?
        start_date = Date.new(year.to_i,(month.to_i)-1,ps.cut_off_date.to_i)
        end_date = Date.new(year.to_i,month.to_i,ps.cut_off_date.to_i-1)
      else
        start_date = Date.new(year.to_i,month.to_i)
        end_date = start_date.at_end_of_month
      end
      absence_type = AbsenceType.find_by_type_id_and_company_id( type_id, company_id)
      if absence_type
        absences = find(:all, :conditions => ['absence_type_id = ? AND absence_date BETWEEN ? AND ?', absence_type.id, start_date, end_date], :order => "absence_date ASC")
      end
      if absences
        total = 1
        max_total = 1
        absences.each_with_index do |absen, index|
          unless absen == absences.last
            next_absen = absences.fetch(index+1)
            if absen.absence_date.tomorrow == next_absen.absence_date
              total += 1
            else
              max_total = total if total > max_total
            end
          end
          max_total = total if total > max_total
        end
        return true if max_total >= total_sequential
      end
      return false
    end

    def total(company_id, month, year, type_ids=[])
      ps = PayrollSetting.find_by_company_id(company_id)
      unless ps.cut_off_date.blank?
        start_date = Date.new(year.to_i,(month.to_i)-1,ps.cut_off_date.to_i)
        end_date = Date.new(year.to_i,month.to_i,ps.cut_off_date.to_i-1)
      else
        start_date = Date.new(year.to_i,month.to_i)
        end_date = start_date.at_end_of_month
      end
      absence_types = AbsenceType.find(:all, :conditions => ['type_id IN (?) AND company_id = ?', type_ids, company_id]).map(&:id)
      if absence_types
        count(:conditions => ['absence_type_id IN (?) AND absence_date BETWEEN ? AND ?', absence_types, start_date, end_date])
      end
    end

    def today
      today = find(:first, :conditions => ['absence_date = ?', Date.today])
      return today
    end
  end
  has_many :presences do

    # termasuk kerja lembur. Misalnya, dia hari Minggu lembur 1 jam, tetap dihitung 1 hari
    def total_attendance_days(month, year)
      beginning_of_month = Time.mktime(year, month)
      end_of_month = beginning_of_month.at_end_of_month
      count(:conditions => ['presence_date BETWEEN ? AND ?', beginning_of_month, end_of_month])
    end

    # tidak termasuk kerja lembur
    def total_work_days(month, year)
      beginning_of_month = Time.mktime(year, month)
      end_of_month = beginning_of_month.at_end_of_month
      work_days = []
      overtimes = Overtime.find(:all, :conditions => ['overtime_date BETWEEN ? AND ?', beginning_of_month, end_of_month]).collect{ |o| o.start_overtime}
      works = find(:all, :conditions => ['presence_date BETWEEN ? AND ?', beginning_of_month, end_of_month])
      works.each do |work|
        presence_detail = work.presence_details.first(:conditions => !{:start_working => overtimes} )
        work_days << presence_detail.presence if presence_detail
      end
      return {:days => work_days.count, :hours => work_days.map{|w| w.presence_length_in_hours.to_f}.sum }
    end

    # Hitung total hari kerja berdasarkan cut off date
    def cut_off_total_work_days(start_date, end_date)
      # cut_off = PayrollSetting.find_by_company_id(self.first.company_id)
      # beginning_of_month = Time.mktime(year, month-1,cut_off.cut_off_date)
      # end_of_month = Time.mktime(year, month,cut_off.cut_off_date-1)
      work_days = []
      overtimes = Overtime.find(:all, :conditions => ['overtime_date BETWEEN ? AND ?', start_date, end_date]).collect{ |o| o.start_overtime}
      works = find(:all, :conditions => ['presence_date BETWEEN ? AND ?', start_date, end_date])
      works.each do |work|
        presence_detail = work.presence_details.first(:conditions => !{:start_working => overtimes} )
        work_days << presence_detail.presence if presence_detail
      end
      return {:days => work_days.count, :hours => work_days.map{|w| w.presence_length_in_hours.to_f}.sum }
    end

    def get_presence_by_periode(pend_date, distance)
      start_date = pend_date-distance.months
      end_date = start_date + 3.months
      # kond = "presence_date > '#{start_date.strftime("%Y-%m-%d")}' AND presence_date<'#{end_date.strftime("%Y-%m-%d")}'"
      kond =  "presence_date BETWEEN DATE(#{start_date}) AND DATE(#{end_date})"
      presence = all(:conditions => kond)
      return presence
    end

    def total_work_days_yearly(year)
      yearly = 0
      (1..12).each do |month|
        yearly += total_work_days(month,year)[:days]
      end
      return yearly
    end

    def today
      today = find(:first, :conditions => ['presence_date = ?', Date.today])
      return today
    end
  end

  has_many :overtimes do
    def total_hours(month, year)
      list_approved(month,year).sum{ |o| o[:total_hours]}
    end

    # return {  :overtime1 => Overtime dgn pengali 1.5,
    # =>        :overtime2 => Overtime dgn pengali 2,
    # =>        :overtime3 => Overtime dgn pengali 3,
    # =>        :overtime4 => Overtime dgn pengali 4 }
    def summary_overtime(start_date, end_date)
      approved_overtimes = find(:all, :conditions => ['overtime_status = ? AND overtime_date BETWEEN ? AND ?',"Approved", start_date , end_date ])
      overtime1 = 0.0
      overtime2 = 0.0
      overtime3 = 0.0
      overtime4 = 0.0
      holiday_hour = 0.0
      person = proxy_owner
      company_id = person.company_id
      holiday = NationalHoliday.holiday_dates(company_id, start_date, end_date)
      compulsory_overtime = 0.0
      (start_date..end_date).each do |date|
        overtime_length = approved_overtimes.find_all{|oo| oo.overtime_date == date }.sum{|ot| ot.overtime_length_in_minutes}
        special_overtime = approved_overtimes.find_all{|oo| oo.overtime_date == date && oo.overtime_type.to_s.upcase.include?("LEMBUR KHUSUS") }.sum{|ot| ot.overtime_length_in_minutes}
        schedule = person.current_schedule(date)
        overtime_in_hours = (overtime_length - special_overtime) / 60.to_f
        special_overtime_in_hours = special_overtime / 60.to_f
        unless compulsory_overtime > 0
          compulsory_overtime = schedule[:compulsory_overtime] / 60.to_f unless schedule.blank?
        end
        if schedule && !holiday.include?(date)
          if overtime_in_hours > 1
            overtime1 += 1
            overtime2 += overtime_in_hours - 1
          else
            overtime1 += overtime_in_hours
          end
        else
          holiday_hour += overtime_in_hours
        end
        overtime2 += special_overtime_in_hours
        if date.wday == 0 || date == end_date
          presence_report = PresenceReport.first(:conditions => ['person_id = ? AND date = ?', person.id, date])
          unless presence_report.blank?
            unless presence_report.unaccounted_noncompulsory_overtime.blank?
              if presence_report.unaccounted_noncompulsory_overtime.to_f > (1 - compulsory_overtime)
                overtime1 += (1 - compulsory_overtime)
                overtime2 += presence_report.unaccounted_noncompulsory_overtime.to_f - (1 - compulsory_overtime)
              else
                overtime1 += presence_report.unaccounted_noncompulsory_overtime.to_f
              end
              compulsory_overtime = 0.0
            end
          end
          if holiday_hour >= 8
            overtime4 += holiday_hour - 8
            overtime3 += 1
            overtime2 += 7
          elsif holiday_hour >= 7
            overtime3 += holiday_hour - 7
            overtime2 += 7
          else
            overtime2 += holiday_hour
          end
          holiday_hour = 0.0
        end
      end
      total_overtime = overtime1 * 1.5 + overtime2 * 2 + overtime3 * 3 + overtime4 * 4
      return {  :overtime1 => overtime1,
        :overtime2 => overtime2,
        :overtime3 => overtime3,
        :overtime4 => overtime4,
        :total => total_overtime.to_f }
    end

    # return [{:date => .., :total_hours => ..., :description => ...}, {...}]
    def list_approved(month, year)
      beginning_of_month = Time.mktime(year, month)
      end_of_month = beginning_of_month.at_end_of_month
      approved_overtimes = find(:all, :conditions => ['overtime_status = ? AND overtime_date BETWEEN ? AND ?',"Approved", beginning_of_month , end_of_month ])
      list_approved = []
      approved_overtimes.each do |overtime|
        overtime_date = Date.parse(overtime.start_overtime.strftime('%Y/%m/%d'))
        overtime_hours = overtime.overtime_length_in_minutes / 60.to_f
        list_approved << {:date => overtime_date, :total_hours => overtime_hours, :description => overtime.overtime_description }
      end
      return list_approved
    end
  end

  has_many :employee_leaves do
    def approved_leaves_count(start_date, end_date)
      approved_leaves(start_date, end_date).count
    end

    def approved_leaves(start_date, end_date)
      all(:conditions => ['leave_date BETWEEN ? AND ? AND leave_status like ?', start_date, end_date, "Approved"],
        :order => "leave_date")
    end
  end


  has_many :leaves_quotas do
    # Jumlah cuti yang tersisa bagi karyawan ini
    # Pertama, cari row di leaves_quotas untuk orang ini di mana start_date <= tanggal hari ini <= end_date
    # Kedua, kalo ketemu, cek kalo misalnya redeem_date gak NULL berarti return 0
    # Ketiga, kalo masih lolos, cek ke employee_leaves udah berapa kali dia cuti. Return quota - jumlah dia udah cuti
    #
    # Cek ke tabel hr_settings.
    # Pertama cek dia udah kerja berapa lama.
    # Bila belum satu tahun bekerja, maka quota bagi dia adalah first_year_quota
    # Bila sudah bekerja lebih dari satu tahun, maka quota bagi dia adalah quota_per_year

    # FIXME: Note by Feby: Tolong rubah saya agar tidak menghitung sisa jatah cuti on the fly
    def remaining_quota(date = Date.today)
      #quota = my_quota(date)
      quota = last
      rv = 0
      if quota
        person = quota.person
        join_leaves = NationalHoliday.join_leaves_count(person.company_id, quota.start_date, quota.end_date)
        leaves = person.employee_leaves.approved_leaves(quota.start_date, quota.end_date)
        leaves_count = leaves.count
        q = quota.quota_val
        unless quota.redeem_date
          quota_now = q - (leaves_count + join_leaves)
        else
          quota_now = q - (leaves_count + quota.redeemed_days + join_leaves)
        end
        # if quota.out_of_quota.blank?
        #   quota.update_attributes(:out_of_quota => leaves[-1 + quota_now].leave_date) if leaves_count > 0 && quota_now <= 0
        # end
        rv = quota_now
      end
      rv
    end

    def my_quota(date = Date.today)
      quota = find(:last, :conditions => ['? BETWEEN start_date AND end_date', date])
      return quota
    end

  end

  attr_accessor :tab_name, :checkedemail, :position_name, :department_name, :division_name, :quota_with_money
  validates_format_of :personal_email, :message => "Formvalidateat email masih salah", :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_blank => true
  
  has_attached_file :headshot, :default_url => :default_headshot, :styles => { :small => "150x150>" }

  has_attached_file :resume
  has_attached_file :ktp, :default_url => :default_ktp, :styles => { :small => "150x150>" }
  has_attached_file :npwp, :default_url => :default_npwp, :styles => { :small => "150x150>" }
  validates_presence_of :firstname, :message => "Nama depan tidak boleh kosong"
  validates_presence_of :employee_identification_number, :message => "NIK tidak boleh kosong"
  
  validates_numericality_of :height_in_cm, :weight_in_kg, :on => :save, :allow_nil => true, :message => "Data yang anda inputkan invalid"
  validates_numericality_of :no_ktp, :message=> "No KTP harus numerik", :allow_blank => true
  validates_numericality_of :no_telp_kontak_darurat, :message => "No Telp harus numerik", :allow_blank=>true
  validates_numericality_of :no_hp, :message => "No HP harus numerik", :allow_blank=>true
  validates_presence_of :employment_date, :message => "Tanggal mulai kerja tidak boleh kosong"
  validates_presence_of :tax_status_id, :message => "Status pajak tidak boleh kosong"


  IMAGE_TYPE = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
  DOCUMENT_TYPE = ['application/msword', 'application/pdf', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
  validates_attachment_content_type :ktp, :content_type => IMAGE_TYPE,
    :allow_blank=>true, :message => "Format upload ktp adalah jpeg/png/gif"
  validates_attachment_content_type :npwp, :content_type => IMAGE_TYPE,
    :allow_blank=>true, :message => "Format upload npwp adalah jpeg/png/gif"
  validates_attachment_content_type :headshot, :content_type => IMAGE_TYPE,
    :allow_blank=>true, :message => "Format upload pasfoto adalah jpeg/png/gif"
  validates_attachment_content_type :resume, :content_type => IMAGE_TYPE + DOCUMENT_TYPE,
    :allow_blank=>true, :message => "Format upload resume adalah doc/pdf/docx/jpeg/png/gif"

  validates_attachment_size :headshot, :less_than => 5.megabytes
  validates_attachment_size :npwp, :less_than => 5.megabytes
  validates_attachment_size :ktp, :less_than => 5.megabytes
  validates_attachment_size :resume, :less_than => 5.megabytes

  named_scope :by_company, lambda {|val| {:conditions => "people.company_id = #{val}"}}

  validate :valid_employee_identification_number_in_the_company


  def absences_for_period(start_date, end_date)
    absences = Absence.find(:all, :conditions => ["person_id = ? and absence_date between ? and ?", self.id, start_date, end_date])
  end

  def self.find_and_make_sure_user_has_access(person_id, current_company_id)
    if person_id and current_company_id
      person = Person.find(:last, :conditions => { :id => person_id, :company_id => current_company_id})
    end
    person
  end

  ## Notes: Method yang dibuat Feby untuk menghitung sisa jatah cuti menggantikan method
  ## remaining_quota yang sering tidak akurat
  def current_leave_quota_days(date = Time.now.to_date)
    days = 0
    leave_quota = self.current_leave_quota(date)
    if leave_quota
      days = leave_quota.quota
      company_holidays = NationalHoliday.join_leaves_count(self.company_id, leave_quota.start_date, leave_quota.end_date)
      absences = self.absences_for_period(leave_quota.start_date.to_s(:db), leave_quota.end_date.to_s(:db))
      leave_quota_used_counts = Absence.count_days_are_cut_employee_leave_quota(absences)
      days = days - (company_holidays + leave_quota_used_counts)
    end
    days = 0 if days < 0
    days
  end

  def create_history_status_pajak
    PeopleTaxStatus.create(:person_id => id, :tax_status_id => tax_status_id,
      :tax_status_start => Date.today.strftime("%Y-%m-%d"))
  end

  def valid_employee_identification_number_in_the_company

    if self.employee_identification_number.match(/^[[:alnum:]]+$/).nil?
      errors.add(:employee_identification_number, "NIK Hanya boleh diisi huruf dan angka")
    else
      if self.id
        cond = "employee_identification_number='#{self.employee_identification_number}' AND company_id=#{self.company_id} AND ID <> #{self.id}"
      else
        cond = "employee_identification_number='#{self.employee_identification_number}' AND company_id=#{self.company_id}"
      end
      
      person = Person.all(:conditions => cond)

      unless person.blank?
        errors.add(:employee_identification_number, "NIK Sudah digunakan")
      end
    end
  end

  def self.without_keluar_masuk(f = nil)
    emp_kond = "(employments.change_from_before!='terminasi' OR employments.change_from_before is NULL) AND (people.latest_employment_id=employments.id)"
    return get_data_person(f, emp_kond)
  end

  def self.is_person_ids_belongs_to_current_company?(person_ids, current_company_id)
    has_access = true
    people = Person.find(:all, :conditions => { :id => person_ids, :company_id => current_company_id } )
    if people.blank?
      has_access = false
    end
    has_access
  end

  def self.with_keluar_masuk(f = nil)
    emp_kond = "(employments.change_from_before='masuk kerja' OR employments.change_from_before='terminasi')"
    if f.blank?
      emp_kond << " AND (month(employments.employment_start)=#{Date.today.month}"
      emp_kond << " OR month(employments.employment_end)=#{Date.today.month})"
      emp_kond << " AND (year(employments.employment_start)=#{Date.today.year}"
      emp_kond << " OR year(employments.employment_end)=#{Date.today.year})"
    else
      unless f[:bulan].blank?
        emp_kond << " AND (month(employments.employment_start)=#{f[:bulan]} OR month(employments.employment_end)=#{f[:bulan]})"
      end
      unless f[:tahun].blank?
        emp_kond << " AND (year(employments.employment_start)=#{f[:tahun]} OR year(employments.employment_end)=#{f[:tahun]})"
      end
    end
    return emp_kond
  end

  def self.with_promotion(f = nil)
    emp_kond = "employments.change_from_before='promosi'"
    return get_data_person(f, emp_kond, "promosi")
  end

  def self.with_mutasi(f = nil)
    emp_kond = "employments.change_from_before='mutasi'"
    return get_data_person(f, emp_kond, "mutasi")
  end

  def self.with_demosi(f = nil)
    emp_kond = "employments.change_from_before='demosi'"
    return get_data_person(f, emp_kond, "demosi")
  end

  def self.get_data_person(f, emp_kond, type_emp = nil)
    kondisi = emp_kond
    unless f.blank?
      filter = search_filter_kondisi(f)
      unless filter.blank?
        kondisi += " AND "
        kondisi += filter
      else
        kondisi += " OR people.latest_employment_id is null " if type_emp.blank?
      end
    end
    return kondisi
  end

  def self.search_filter_kondisi(f)
    person_kond = ""
    emp_kondisi = ""

    person_kond << "CONCAT(TRIM(people.firstname),' ',TRIM(people.lastname)) like '%#{f[:name]}%'" unless f[:name].blank?

    unless f[:tahun_kontrak].blank?
      workcontract  = WorkContract.all(:conditions => "YEAR(contract_end)= '#{f[:tahun_kontrak]}'")
      workcontract_id = workcontract.collect{|x| "#{x.id}"}
      person_kond << " and " unless person_kond.blank?
      person_kond << "people.latest_work_contract_id in ('#{workcontract_id.join("','")}')"
    end

    unless f[:bulan_kontrak].blank?
      workcontract  = WorkContract.all(:conditions => "MONTH(contract_end)= '#{f[:bulan_kontrak]}'")
      workcontract_id = workcontract.collect{|x| "#{x.id}"}
      person_kond << " and " unless person_kond.blank?
      person_kond << "people.latest_work_contract_id in ('#{workcontract_id.join("','")}')"
    end

    unless f[:blood_type].blank?
      person_kond << " and "unless person_kond.blank?
      person_kond << "people.blood_type = '#{f[:blood_type]}'"
    end

    unless f[:gender].blank?
      person_kond << " and "unless person_kond.blank?
      person_kond << "people.gender = '#{f[:gender]}'"
    end

    unless f[:nik].blank?
      person_kond << " and " unless person_kond.blank?
      person_kond << "people.employee_identification_number like '%#{f[:nik]}%'"
    end

    unless f[:pendidikan_terakhir].blank?
      person = find_by_education(f[:pendidikan_terakhir])
      person_id = person.collect{|x| "#{x.person_id}"}
      person_kond << " and "unless person_kond.blank?
      person_kond << "people.id in ('#{person_id.join("','")}')"
    end

    unless f[:department_id].blank?
      emp_kondisi << " and "unless emp_kondisi.blank?
      emp_kondisi << "employments.department_id = '#{f[:department_id]}'"
    end

    unless f[:division_id].blank?
      emp_kondisi << " and "unless emp_kondisi.blank?
      emp_kondisi << "employments.work_division_id = '#{f[:division_id]}'"
    end

    unless f[:position_id].blank?
      emp_kondisi << " and " unless emp_kondisi.blank?
      emp_kondisi << "employments.position_id = '#{f[:position_id]}'"
    end

    # baca employment berdasarkan kondisi divisi relasi
    emp = Employment.find(:all, :conditions => emp_kondisi)
    emp_id = emp.collect{|x| "#{x.id}"}

    unless emp_kondisi.blank?
      person_kond << " and " unless person_kond.blank?
      person_kond << "people.latest_employment_id in ('#{emp_id.join("','")}')"
    end

    unless f[:contract_type_id].blank?
      workcontract  = WorkContract.all(:conditions => "contract_type_id = '#{f[:contract_type_id]}'")
      workcontract_id = workcontract.collect{|x| "#{x.id}"}
      person_kond << " and " unless person_kond.blank?
      person_kond << "people.latest_work_contract_id in ('#{workcontract_id.join("','")}')"
    end

    person = Person.all(:conditions => person_kond, :order => "CONCAT( people.FirstName, people.LastName )")

    unless f[:year].blank?
      person_id = lama_kerja(person,f)
      person_kond = person_id .count > 0 ? "people.id in (#{person_id .join(',')})" : "people.id IS NULL"
    end
    return person_kond
  end

  def self.search_by_formasi(f, ids_person_by_company, company_id)
    kond = str_kond_formasi(f, ids_person_by_company)
    unless kond.blank?
      emp = Employment.all(:conditions => kond, :include => :person)
      data_chart = Employment.get_chart_formasi( ids_person_by_company) if f[:filter] == "formasi"
      data_chart = Employment.get_chart_formasi_jabatan(emp, company_id) if f[:filter] == "formasi_jabatan"
      data_chart = Employment.get_chart_formasi_departemen(emp, company_id) if (f[:filter] == "formasi_departemen") #|| ((f[:filter] == "formasi_bagian") && (f[:department_id].blank?))
      data_chart = Employment.get_chart_formasi_bagian(emp, company_id) if f[:filter] == "formasi_bagian" #&& !f[:department_id].blank?
      return {:data_chart => data_chart}
    else
      return {:person => nil, :data_chart => nil}
    end
  end

  #"select IF (employment_end IS NULL, 2099-1-1, employment_end) AS employment_end_not_null from employments"
  def self.str_kond_formasi(f, ids_person_by_company)
    kond = "employments.employment_start <= '#{Person.format_date(f[:employment_start])}' AND IF (employments.employment_end IS NULL, '2099-01-01', employments.employment_end) >= '#{Person.format_date(f[:employment_start])}' AND (employments.change_from_before!='terminasi' OR employments.change_from_before is NULL) AND (people.latest_employment_id=employments.id)"
    unless f[:work_division_id].blank?
      kond += " AND" unless kond.blank?
      kond += " employments.work_division_id = #{f[:work_division_id]}"
    end
    unless f[:department_id].blank?
      kond += " AND" unless kond.blank?
      kond += " employments.department_id = #{f[:department_id]}"
    end
    unless ids_person_by_company.blank?
      kond += " AND" unless kond.blank?
      kond += " employments.person_id in ('#{ids_person_by_company.join("','")}')"
    end unless kond.blank?
    kond += " AND (employments.change_from_before != 'terminasi') " unless kond.blank?
    return kond
  end

  def self.search_by_gender_status(f, conditions)
    kond = conditions
    unless f[:contract_type_id].blank?
      work_kond = "contract_type_id='#{f[:contract_type_id]}'"
      work = WorkContract.all(:conditions => work_kond)
      person_id = work.collect {|x| x.person_id}.compact.uniq
      kond = " people.id in ('#{person_id.join("','")}')"
    end
    unless f[:gender].blank?
      kond += " AND" unless kond.blank?
      kond += " people.gender='#{f[:gender]}'"
    end
    person = Person.all(:conditions => kond)
    return person
  end

  def self.search_by_mutasi(f)
    a = {:data_chart => nil}
    kond = str_kond_mutasi(f)
    unless kond.blank?
      emp = Employment.all(:include => [:person], :conditions => kond)
      unless emp.blank?
        data_chart = Employment.get_range_month(emp, f)
        a = {:data_chart => data_chart}
      end
    end
    return a
  end

  def self.str_kond_mutasi(f)
    kond = ""
    unless f[:tahun].blank?
      kond += " AND" unless kond.blank?
      kond += " (YEAR(employments.employment_start)='#{f[:tahun]}' OR YEAR(employments.employment_end)='#{f[:tahun]}')"
    end
    if !f[:bulan].blank?
      kond += " AND" unless kond.blank?
      kond += " (MONTH(employments.employment_start)='#{f[:bulan]}' OR MONTH(employments.employment_end)='#{f[:bulan]}')"
    end

    unless f[:work_division_id].blank?
      kond += " AND" unless kond.blank?
      kond += " employments.work_division_id='#{f[:work_division_id]}'"
    end

    unless f[:position_id].blank?
      kond += " AND" unless kond.blank?
      kond += " employments.position_id='#{f[:position_id]}'"
    end

    unless f[:work_group_id].blank?
      kond += " AND" unless kond.blank?
      kond += " employments.work_group_id='#{f[:work_group_id]}'"
    end
    kond += " AND " unless kond.blank?
    kond += "(employments.change_from_before='masuk kerja' or employments.change_from_before='terminasi')"
  end

  def self.search_by_status(f, ids_person_by_company, company_id)
    kond = str_kond_status(f, ids_person_by_company)
    unless kond.blank?
      contract = WorkContract.all(:conditions => kond)
      unless contract.blank?
        data_chart = WorkContract.get_chart_status(contract,  company_id)
        return {:contract => contract, :data_chart => data_chart}
      end
    end
    return {:contract => nil, :data_chart => nil}
  end

  def self.str_kond_status(f, ids_person_by_company)
    kond = "contract_start <= '#{Person.format_date(f[:employment_start])}' AND IF (contract_end IS NULL, '2099-01-01',contract_end) >= '#{Person.format_date(f[:employment_start])}'"
    unless ids_person_by_company.blank?
      kond += " AND"
      kond += " person_id in ('#{ids_person_by_company.join("','")}')"
    end unless kond.blank?
    return kond
  end

  def self.search_by_sp(f, ids_person_by_company)
    kond = str_kond_sp(f, ids_person_by_company)
    sp = Violation.all(:conditions => kond) unless kond.blank?
    unless sp.blank?
      data_chart = Violation.get_chart_sp(sp, f)
      return data_chart
    end
    return {:bulan => nil, :warning => nil, :sp1 => nil, :sp2 => nil, :sp3 => nil, :is_warning_nil => true, :is_sp1_nil => true, :is_sp2_nil => true, :is_sp3_nil => true}
  end

  def self.str_kond_sp(f, ids_person_by_company)
    kond = ""
    unless f[:tahun].blank?
      kond += " AND" unless kond.blank?
      kond += " (YEAR(occurence_date)='#{f[:tahun]}' OR YEAR(occurence_date)='#{f[:tahun]}')"
    end
    if !f[:bulan].blank?
      kond += " AND" unless kond.blank?
      kond += " (MONTH(occurence_date)='#{f[:bulan]}' OR MONTH(occurence_date)='#{f[:bulan]}')"
    end

    unless (f[:tahun].blank? && f[:bulan].blank?)
      unless ids_person_by_company.blank?
        kond += " AND" unless kond.blank?
        kond += " person_id in ('#{ids_person_by_company.join("','")}')"
      end
    end
  end

  def self.search_by_accident(f, ids_person_by_company)
    kond = str_kond_accident(f, ids_person_by_company)
    unless kond.blank?
      accident = Accident.all(:conditions => kond)
      unless accident.blank?
        data_chart = Accident.get_chart_accident(accident, f)
        return data_chart
      end
    end
    return {:bulan => nil, :value => nil, :is_nil => true}
  end

  def self.str_kond_accident(f, ids_person_by_company)
    kond = ""
    unless f[:tahun].blank?
      kond += " AND" unless kond.blank?
      kond += " YEAR(accident_date)='#{f[:tahun]}'"
    end
    unless f[:bulan].blank?
      kond += " AND" unless kond.blank?
      kond += " MONTH(accident_date)='#{f[:bulan]}'"
    end
    unless ids_person_by_company.blank?
      kond += " AND" unless kond.blank?
      kond += " person_id in ('#{ids_person_by_company.join("','")}')"
    end
  end

  def self.find_by_kedudukan(id, sign)

  end

  def options
    {  :gender => ['Pria','Wanita'],
      :marital_status => ['Tidak menikah','Menikah','Bercerai','Janda/Duda'],
      :blood_type => ['a','b','ab','o'],
      :religion => ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Budha', 'Konghucu']
    }
  end

  def self.person_religion
    ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Budha', 'Konghucu']
  end

  def exp_by_type(type)
    case type
    when "work"
      experiences.find(:all, :conditions => "experience_type = 'work'", :order => 'start_date DESC')
    when "training"
      experiences.find(:all, :conditions => "experience_type = 'training'", :order => 'start_date DESC')
    when "organizational"
      experiences.find(:all, :conditions => "experience_type = 'organizational'", :order => 'start_date DESC')
    end
  end

  def position_in_family
    families.find(:all, :conditions => "relationship_to_person = 'kakak'").count + 1
  end

  def home_address
    home = addresses.find(:first)
    return "#{home.street1} #{home.city}, #{home.state}"
  end

  def current_address
    if addresses.blank?
      Address.new
    else
      addresses.find(:first)
    end
  end

  def current_position(date=Date.today)
    employment = self.employment(date)
    if employment
      return employment.position
    end
  end

  def current_work_contract
    unless self.latest_work_contract_id.blank?
      return WorkContract.find_by_id(self.latest_work_contract_id)
    else
      return nil
    end
  end

  def current_employment(date = Date.today, is_list_terminasi = false)
    e = self.employments(:sort => :employment_start)
    if e.blank?
      return nil
    else
      unless self.latest_employment_id.blank?
        emp = Employment.find_by_id(self.latest_employment_id)
        return emp
        #        FIXME: logika aneh, ada if else tapi 2 2 nya return value yang sama
        #        if is_list_terminasi
        #          return emp
        #        else
        #          return emp if emp.employment_end.blank? || emp.employment_end >= date
        #        end
      else
        if e.last.employment_end.blank?
          return e.last
        else
          return e.last if e.last.employment_end > date
        end
      end
    end
    return nil
  end

  def current_status
    e = self.work_contracts
    if e.blank?
      return WorkContract.new
    else
      return WorkContract.find(latest_work_contract_id) unless latest_work_contract_id.blank?
    end
    return nil
  end

  # Ambil gaji terakhir, kalau tidak ada, ambil dari data master gaji.
  def current_salary
    last_honor = Honor.find(:last, :conditions => "person_id = #{self.id} AND !is_thr", :order => 'honor_date ASC' )
    unless last_honor.blank?
      return last_honor
    else
      return nil
    end
  end

  def current_salary_data_master
    data_master = self.salary_master_data
    unless data_master.blank?
      return data_master
    else
      return nil
    end
  end

  def get_current_salary(honor)
    salary = 0
    salary = self.current_salary.salary.to_i unless self.current_salary.blank?
    salary = self.current_salary_data_master.basic_salary.to_i if !self.current_salary_data_master.blank? && honor.salary.blank?
    return salary
  end

  def self.param_date_to_str(person)
    return person
  end

  def deem_as_working(work_date, description, duration = nil)
    presence = self.presences.find_by_presence_date(work_date)
    absence = self.absences.find_by_absence_date(work_date)
    unless presence
      schedule = self.current_schedule(work_date)
      presence = self.presences.new
      presence.presence_date = work_date
      presence.company_id = self.company_id
      if duration > 0
        presence.presence_length_in_hours = duration
        presence.paid_hours = duration
      else
        presence.presence_length_in_hours = schedule[:length]
        presence.break_length_in_minutes = schedule[:break_length]
        presence.paid_hours = schedule[:length]
      end
      presence.presence_description = description
      presence.set_is_acted_upon(32)
      detail = presence.presence_details.new
      if duration > 0
        detail.start_working = schedule[:schedule_start]
        detail.end_working = detail.start_working + duration.hours
      else
        detail.start_working = schedule[:schedule_start]
        detail.end_working = detail.start_working + schedule[:length].to_i.hours
      end
      detail.calculate_time
      presence.calculate_work_time(presence.break_length_in_minutes)
      presence.calculate_overtime unless schedule.blank?
      presence.save!
      if absence
        absence.destroy
        # Hapus employee_leaves ketika cuti dianggkap kerja.
        leave = self.employee_leaves.find_by_leave_date(absence.absence_date)
        leave.destroy unless leave.blank?
      end
    end
    return presence
  end

  def employment(date = Date.today)
    person_employment = self.employments.find(:last, :conditions => ['employment_start <= ?', date], :order => "employment_start ASC")
    unless person_employment.blank?
      if person_employment.employment_end.nil?
        return person_employment
      else
        return self.employments.find(:last, :conditions => ['? BETWEEN employment_start AND employment_end', date])
      end
    else
      return nil
    end
  end

  def department(date = Date.today)
    employment = self.employment(date)
    if employment
      return employment.department
    end
  end

  def division(date = Date.today)
    employment = self.employment(date)
    if employment
      return employment.division
    end
  end

  def work_group(date = Date.today)
    employment = self.employment(date)
    if employment
      return employment.work_group
    end
  end

  def current_leave_quota(date = Time.now.to_date)
    active_leave_quota = self.leaves_quotas.last(:conditions => ['? BETWEEN start_date AND end_date', date] )
    if self.leaves_quotas.blank? or active_leave_quota.blank?
      active_leave_quota = self.leave_quota
    end
    active_leave_quota

  end

  ## FIXME: Logic nya susah dibaca dan membingungkan bahwa method ini itu untuk
  ##        mengembalikan jatah cuti atau membuat baru
  def leave_quota(date = Date.today)
    leaves_quotas = self.leaves_quotas
    hr_setting = HrSetting.last(:conditions => ['company_id = ?', self.company_id])
    contracts = self.work_contracts.all(:order => "contract_start")
    if leaves_quotas.blank?
      if contracts
        contracts.each_with_index do |contract, c_idx|
          date_quota_start = contract.contract_start.to_date
          date_quota_end = contract.contract_end.to_date unless contract.contract_end.blank?
          date_quota = date_quota_start
          if date_quota_end.blank?
            (date_quota_start.year .. date.to_date.year+1).each_with_index do |d, index|
              quota = self.leaves_quotas.new(:start_date => date_quota)
              quota.company_id = self.company_id
              date_quota += 1.year
              quota.end_date = date_quota - 1.day
              unless quota.end_date < Date.today
                if index == 0 && c_idx == 0
                  quota.quota = hr_setting.leaves_first_year_quota
                else
                  quota.quota = hr_setting.leaves_quota_per_year
                end
              else
                quota.quota = 0
              end
              quota.save!
            end
          else
            (date_quota_start.year..date_quota_end.year).each_with_index do |d, index|
              if date_quota < date_quota_end
                quota = self.leaves_quotas.new(:start_date => date_quota)
                quota.company_id = self.company_id
                date_quota += 1.year
                quota.end_date = date_quota - 1.day
                quota.end_date = date_quota_end if quota.end_date > date_quota_end
                unless quota.end_date < Date.today
                  if index == 0 && c_idx == 0
                    quota.quota = hr_setting.leaves_first_year_quota
                  else
                    quota.quota = hr_setting.leaves_quota_per_year
                  end
                else
                  quota.quota = 0
                end
                quota.save!
              end
            end
          end
        end
      end
    else
      leave_quota = self.leaves_quotas.last(:conditions => ['? BETWEEN start_date AND end_date', date] )
      unless leave_quota
        contract = contracts.last
        if contract
          last_quota = self.leaves_quotas.last(:order => "start_date" )
          quota_start_date = last_quota.start_date + 1.year
          quota_end_date = last_quota.end_date + 1.year
          if contract.contract_end.blank?
            (quota_start_date.year..date.to_date.year+1).each_with_index do |d, index|
              quota = self.leaves_quotas.new(:start_date => quota_start_date,
                :end_date => quota_end_date,
                :quota => hr_setting.leaves_quota_per_year)
              quota.company_id = self.company_id
              quota.save!
              quota_start_date += 1.year
              quota_end_date += 1.year
            end
          elsif contract.contract_end.to_date > date.to_date
            if contract.contract_start.to_date > last_quota.start_date.to_date
              quota_start_date = contract.contract_start.to_date
              quota_end_date = quota_start_date + 1.year - 1.day
              quota_end_date = contract.contract_end.to_date if contract.contract_end.to_date < quota_end_date
            end
            (quota_start_date.year..contract.contract_end.to_date.year).each_with_index do |d, index|
              if quota_start_date < contract.contract_end.to_date
                quota = self.leaves_quotas.new(:start_date => quota_start_date,
                  :end_date => quota_end_date,
                  :quota => hr_setting.leaves_quota_per_year)
                quota.company_id = self.company_id
                quota.save!
                quota_start_date += 1.year
                quota_end_date += 1.year
                quota_end_date = contract.contract_end.to_date if contract.contract_end.to_date < quota_end_date
              end
            end
          end
        end
      else
        return leave_quota
      end
    end
    return self.leaves_quotas.last(:conditions => ['? BETWEEN start_date AND end_date', date] )
  end

  def current_shift(date)
    shift = nil
    employment = self.employment(date)
    unless employment.blank?
      employee_shift = self.employee_shifts.find(:last, :conditions => ['? BETWEEN shift_from AND shift_to ', date], :order => :shift_from)
      unless employee_shift.blank?
        shift = employee_shift.shift
      end
    end
    return shift
  end

  def current_schedule(date)
    shift = self.current_shift(date)
    unless shift.blank?
      shift_name = shift.shift_name

      daily_schedule = shift.daily_schedule(date) if shift
      unless daily_schedule.blank?
        schedule_start = daily_schedule.start_time
        schedule_end = daily_schedule.end_time
        schedule_length = daily_schedule.length_in_hours
        break_length = daily_schedule.break_length_in_minutes
        compulsory_overtime = daily_schedule.compulsory_overtime_in_minutes
        shift_category = shift.shift_category
        if schedule_start == schedule_end
          return nil
        end
        if schedule_end < schedule_start
          schedule_end = Time.mktime(date.tomorrow.year, date.tomorrow.month, date.tomorrow.day, schedule_end.hour, schedule_end.min)
        else
          schedule_end = Time.mktime(date.year, date.month, date.day, schedule_end.hour, schedule_end.min)
        end
        schedule_start = Time.mktime(date.year, date.month, date.day, schedule_start.hour, schedule_start.min)
      else
        return nil
      end
    else
      return nil
    end
    if schedule_length.to_i == 0
      return nil
    else
      return {:shift_name => shift_name, :schedule_start => schedule_start,
        :schedule_end => schedule_end, :schedule_length => schedule_length,
        :break_length => break_length, :compulsory_overtime => compulsory_overtime,
        :shift_category => shift_category
      }
    end
  end

  # Hitung total lembur wajib antara start_date dan end_date dalam menit
  def total_compulsory_overtimes(start_date, end_date)
    total = self.overtimes.sum(:overtime_length_in_minutes, :conditions => ['overtime_date BETWEEN ? AND ? AND overtime_status = ? AND overtime_type = ?', start_date, end_date, "Approved", "Lembur Wajib"])
    return total
  end

  def self.find_by_education(item)
    Education.all(:select=> :person_id, :conditions => "pendidikan_terakhir='#{item}'")
  end

  # return in seconds
  def self.lama_kerja(person,f)
    id = []
    person.each do |p|
      search_lama_kerja = time_length_date(f[:year])
      lama_kerja = 0
      lama_kerja = p.total_length_of_service(p) unless p.employment_date.blank?
      if f[:sign_year] == "Lebih dari"
        id << p.id if lama_kerja > search_lama_kerja
      else
        id << p.id if lama_kerja < search_lama_kerja
      end
    end
    return id
  end

  def self.time_length_date(tahun)
    length_date = (DateTime.now.to_date - (tahun.to_i*360))
    return Time.now - length_date.to_time
  end

  def total_length_of_service(person)
    length = 0
    if person.current_employment.blank?
      length = Time.now - person.employment_date.to_time unless person.employment_date.blank?
    else
      if person.current_employment.change_from_before == "terminasi"
        length = person.current_employment.employment_end.to_time - person.employment_date.to_time
      else
        length = Time.now - person.employment_date.to_time
      end
    end
    return length
  end

  def full_name
    "#{self.firstname} #{self.lastname}"
  end

  def my_unpaid_absences(start_date, end_date)
    rv = []
    list_unpaid = self.absences.list_total_unpaid(self.company_id, start_date, end_date)

    #list_unpaid = list_unpaid.collect{ |x| x if x.count_on_salary_cut? }.compact unless  list_unpaid.blank?
    #list_unpaid = list_unpaid.blank? ? [] : list_unpaid
    list_unpaid.each do |absence|
      rv << absence if !absence.is_cut_employee_leave_quota
    end
    
    rv
  end

  def full_data_name
    dept = ""
    div = ""
    data = [self.full_name, self.employee_identification_number]
    unless self.current_employment.blank?
      unless self.current_employment.department.blank?
        dept = self.current_employment.department.department_name
        data << dept
      end

      unless self.current_employment.division.blank?
        div = self.current_employment.division.name
        data << div
      end
    end
    return "#{data.join(" , ")}"
  end

  def self.first_last_name(full_name)
    temp = full_name.split(" ")
    if temp.count == 0
      return {:first_name => temp, :last_name => ""}
    else
      first_name = ""
      last_name = ""
      temp.each.with_index do |x,index|
        if index == 0
          first_name = x
        else
          if index == (temp.count-1)
            last_name << "#{x}"
          else
            last_name << "#{x} "
          end
        end
      end
      return {:first_name => first_name, :last_name => last_name}
    end
    return first_name
  end

  def self.get_user_and_karyawan(puser)
    is_success = false
    data = get_data_user(puser)
    data_karyawan = data[:data_karyawan]
    data_user = data[:data_user]#{:company_id=>1, :password=>"2107917a481a6880fba3dd1f9970ad39d3e00cbc", :email=>"nurlela@nurlela.com", :token_string=>"glavekngdyersdndylixhczlyzfsjukcmejkngpq", :password_confirmation=>"2107917a481a6880fba3dd1f9970ad39d3e00cbc", :name=>"Nur ayam"}#data[:data_user]
    user = User.find_by_email(data_user[:email])
    if user.blank?
      user= User.new(data_user)
      if user.save
        user_company = UserCompany.new(:user_id => user.id, :company_id => data_user[:company_id])
        user_company.save
        is_success = true
      end
    else
      if user.update_attributes(data_user)
        user_company = UserCompany.find_by_company_id(data_user[:company_id])
        if user_company.blank?
          user_company = UserCompany.new(:user_id => user.id, :company_id => data_user[:company_id])
          user_company.save
        else
          user_company.update_attribute(:user_id, user.id)
        end
        is_success = true
      end
    end

    unless puser['id'].blank?
      karyawan =  Person.find(puser['id'])
      karyawan.update_attributes(data_karyawan.merge(:user_id => user.id))
      is_success = true;
    end
    return is_success
  end

  def self.get_data_user(puser)
    data_user = {
      :name => "#{puser['first_name']} #{puser['last_name']}",
      :email => puser['email'],
      :password => puser['password_confirmation'],
      :password_confirmation => puser['password_confirmation'],
      :token_string => puser['token_string'],
      :company_id => puser['company_id']
    }
    data_karyawan = {
      :firstname => "#{puser['first_name']}",
      :lastname => "#{puser['last_name']}",
      :personal_email => puser['email'],
      :company_id => puser['company_id']
    }
    return {:data_user => data_user, :data_karyawan => data_karyawan}
  end

  def self.format_date(str_date)
    a =  str_date.split("/")
    return "#{a[2]}-#{a[1]}-#{a[0]}"
  end

  def self.format_date2(str_date)
    a =  str_date.split("-")
    return "#{a[2]}/#{a[1]}/#{a[0]}"
  end

  def self.get_person_name_by_department_and_division(pnama, company_id)
    p = nil
    unless pnama.blank?
      if pnama.include? ","
        nama = name_split(pnama)
        p = Person.first(:conditions => "employee_identification_number= '#{nama[1].strip}' AND company_id = #{company_id}")
      end
    end
    return p
  end

  def self.name_split(nama)
    data = nama.split(",")
    return data
  end

  def self.second_to_days1(sec)
    lama = ""
    lama_tahun = 60*60*24*30*12
    lama_bulan = 60*60*24*30
    if sec > 0
      tahun = (sec/ lama_tahun).to_i
      if tahun == 0
        month = (sec / lama_bulan).to_i
        lama = "#{month} bulan"
      else
        month = ((sec % (lama_tahun))/(lama_bulan)).to_i
        lama = "#{tahun} tahun, #{month} bulan"
      end
    end
    return lama
  end

  # 3 months = 7884000 seconds
  def more_than_three_months
    if self.total_length_of_service(self) >= 7884000
      return true
    else
      return false
    end
  end

  # Return company hr setting
  def company_hr_setting
    hr_setting = HrSetting.find_by_company_id(self.company_id)
  end

  # Return company payroll setting
  def company_payroll_setting
    payroll_setting = PayrollSetting.find_by_company_id(self.company_id)
  end

  def began_to_work
    self.employments(:order => 'employment_start ASC').first if !self.employments.blank?
  end

  def self.find_from_params(conditions, options={})
    limit = options[:display_length]
    offset = options[:start_index]

    unless limit.blank?
      people = Person.all(:conditions => conditions, :include=> [:employments], :order => "firstname", :limit => limit, :offset => offset )
    else
      people = Person.all(:conditions => conditions, :include=> [:employments], :order => "firstname")
    end
  end

  def self.check_data(current_company_id,holding_id,person,current_company,current_user)
    check = self.find_by_company_id_and_holding_company_id(current_company_id,holding_id)
    if check.blank? 
      puts "    Running People"
      
      (1..5).each do |d|
        name = person[:name].rand
        date = Date.today - 2.month
        birth_date        = "#{(1982..1993).to_a.rand}-#{(1..12).to_a.rand}-#{(1..30).to_a.rand}"
        employment_date   = "#{(2005..2012).to_a.rand}-#{(1..12).to_a.rand}-#{(1..30).to_a.rand}"
        # employment_start  = "#{(2012..2013).to_a.rand}-#{(1..12).to_a.rand}-#{(1..30).to_a.rand}"
        employment_start  = "#{date.year}-#{date.mon}-1"
        employment_end    = "#{(date+1.year).year}-#{(1..12).to_a.rand}-#{(1..30).to_a.rand}"
        position = Position.find(:all,:conditions => ["company_id = ?",current_company_id]).rand
        division = Division.find(:all,:conditions => ["company_id = ? and holding_company_id = ?",current_company_id,holding_id]).rand
        type_emp = EmploymentType.all.rand
        work_group = WorkGroup.find(:all,:conditions => ["company_id = ? and division_id = ?",current_company_id,division.id]).rand
        tax_status = TaxStatus.find(:all,:conditions => ["company_id = ? ",current_company_id]).rand
        contract = ContractType.find(:all,:conditions => ["company_id = ? ",current_company_id]).rand

        data = Person.new()
        data.user_id              = current_user.id
        data.company_id           = current_company_id
        data.holding_company_id   = holding_id
        data.no_ktp               = "#{'%011d' % rand(1e10)}"
        data.no_npwp              = "#{'%011d' % rand(1e10)}"
        data.firstname            = name
        data.lastname             = person[:name].rand
        data.gender               = person[:gender].rand
        data.city_of_birth        = person[:city].rand
        data.birth_date           = Date.parse birth_date
        data.religion             = person[:religion].rand
        data.no_hp                = "#{'%011d' % rand(1e10)}"
        data.personal_email       = "#{name}_#{rand(20)}@#{current_company}.com"
        data.marital_status       = person[:marital_status].rand
        data.blood_type           = person[:blood_type].rand
        data.height_in_cm         = rand(100) + rand(150) + 2
        data.weight_in_kg         = rand(50) + rand(100) + 2
        data.color_blind          = person[:color_blind].rand
        data.tax_status_id        = tax_status.id
        data.employee_identification_number = "#{rand(5**8)}"
        data.employment_date      = Date.parse employment_start
        data.nama_kontak_darurat  = person[:name].rand
        data.no_telp_kontak_darurat = "#{'%011d' % rand(1e10)}"
        data.relasi_kontak_darurat = "#{'%011d' % rand(1e10)}"
        data.known_illnesses      = "#{'%011d' % rand(1e10)}"
        data.position_name = position.id
        data.department_name = division.department.id
        data.division_name= division.id
        if data.save
          employment = Employment.new()
          employment.person_id           = data.id
          employment.department_id       = division.department.id
          employment.work_division_id    = division.id
          employment.position_id         = position.id
          employment.employment_type_id  = type_emp.id
          employment.work_group_id       = work_group.id
          employment.employment_start    = Date.parse employment_start
          employment.employment_end      = Date.parse employment_end
          employment.change_from_before = "masuk kerja"
          employment.save!
          new_contract = WorkContract.new()
          new_contract.company_id = current_company_id
          new_contract.person_id = data.id
          new_contract.contract_type_id = contract.id
          new_contract.contract_start = Date.parse employment_start
          new_contract.contract_end = Date.parse employment_end
          new_contract.is_daily_employee = 0
          new_contract.is_daily_employee = 0
          new_contract.save!
          # require "pp"
          # pp employment.errors.full_messages
          update_person = Person.find(data.id)
          update_person.update_attributes({:latest_employment_id => employment.id,:employment_id => employment.id})
          pp employment.errors.full_messages
        end
      end
    end
  end

  private
  def default_headshot
    "no-avatar.jpg"
  end

  def default_ktp
    "ktp.jpg"
  end

  def default_npwp
    "npwp.jpg"
  end
end


