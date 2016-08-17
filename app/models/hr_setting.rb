# == Schema Information
#
# Table name: hr_settings
#
#  id                            :integer(4)      not null, primary key
#  company_id                    :integer(4)
#  lateness_tolerance_in_minutes :integer(4)
#  period_in_minutes             :integer(4)
#  leaves_first_year_quota       :integer(4)
#  leaves_quota_per_year         :integer(4)
#  created_at                    :datetime
#  updated_at                    :datetime
#

class HrSetting < ActiveRecord::Base
  validates_presence_of :lateness_tolerance_in_minutes , :message =>'Data tidak boleh kosong'
  validates_presence_of :period_in_minutes , :message =>'Data tidak boleh kosong'
  validates_presence_of :leaves_first_year_quota , :message =>'Data tidak boleh kosong'
  validates_presence_of :leaves_quota_per_year , :message =>'Data tidak boleh kosong'

  validates_numericality_of :lateness_tolerance_in_minutes , :message =>'Input harus angka'
  validates_numericality_of :period_in_minutes , :message =>'Input harus angka'
  validates_numericality_of :leaves_first_year_quota , :message =>'Input harus angka'
  validates_numericality_of :leaves_quota_per_year , :message =>'Input harus angka'

  attr_protected :company_id
  after_create :update_employee_quota

  def self.initializer(company_id)
    setting_initializer(company_id)
    AbsenceType.initializer(company_id)
    TaxStatus.initializer(company_id)
    NationalHoliday.initializer(company_id)
  end 

  def self.setting_initializer(company_id)
    hr = HrSetting.find_by_company_id(company_id)
    if hr.blank?
      hr = HrSetting.new(:lateness_tolerance_in_minutes => 10,
        :period_in_minutes => 15,
        :leaves_first_year_quota => 12,
        :leaves_quota_per_year => 12
      )
      hr.company_id = company_id
      hr.save
    end
  end

  def self.prepare_notification(company_id)
    setting = HrSetting.find_by_company_id(company_id)
    data = []
    unless setting.blank?
      data << ["Alat Sidik Jari","Alat absensi sidik jari belum terhubung.","#fingerprint_settings"] if !setting.fingerprint_device_is_set
      data << ["Alat Sidik Jari","Alat sidik jari tidak dapat terkoneksi. Harap cek koneksi jaringan alat tersebut dan settingnya","#fingerprint_settings"] if setting.fingerprint_device_is_set && !setting.fingerprint_device_is_connected
      data << ["Penjadwalan","Ada #{setting.no_schedule} karyawan yang tidak memiliki jadwal kerja.","#person_not_schedule"] if setting.schedule_is_set && setting.no_schedule.to_i > 0
      data << ["Karyawan","Data karyawan belum diisi.","#person_index"] if !setting.employee_is_set
      data << ["Shift", "Shift kerja belum diisi","#shifts"] if !setting.shift_is_set
      data << ["Penjadwalan","Penjadwalan kerja belum diisi","#schedules"] if !setting.schedule_is_set
      data << ["Payroll","Payroll setting belum diisi.","#payrollsd"] if !setting.payroll_setting_is_set
    end
    return data
  end


  def self.is_notification_action(params)
    return params[:action] == "create" || params[:action] =="update" || params[:action] =="destroy" ||
      params[:action] == "delete_multiple"
  end

  def self.person_not_schedule(company_id, page)
    conditions = "people.id NOT IN (select person_id from employee_shifts where shift_from < '#{Date.today.to_s(:db)}' AND shift_to >= '#{Date.today.to_s(:db)}' AND company_id = #{company_id})AND company_id = #{company_id}"
    people = Person.paginate(:all, :conditions => conditions, :page => page, :per_page => 10, :order => 'firstname ASC, lastname ASC')
    return people
  end

  def update_employee_quota
    company_id = self.company_id
    people = Person.all(:conditions => ["company_id = ?", company_id])
    people.each do |person|
      leave_quotas = person.leaves_quotas.all(:order => "start_date")
      if leave_quotas
        leave_quotas.each do |quota|
          unless quota == leave_quotas.first
            quota.quota = self.leaves_quota_per_year.to_i
            quota.save
          else
            quota.quota = self.leaves_first_year_quota.to_i
            quota.save
          end
        end
      end
    end
  end

end
