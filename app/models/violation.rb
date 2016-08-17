# == Schema Information
#
# Table name: violations
#
#  id                    :integer(4)      not null, primary key
#  person_id             :integer(4)
#  violation_category    :string(255)
#  violation_description :text
#  occurence_date        :date
#  action_taken          :string(255)
#  active_until          :date
#  created_at            :datetime
#  updated_at            :datetime
#  person_in_charge_name :string(255)
#  company_id            :integer(4)
#

class Violation < ActiveRecord::Base

  belongs_to :person
  validates_presence_of :violation_category
  validates_presence_of :violation_category, :message => "Kategori tidak boleh kosong"
  validates_presence_of :action_taken, :message => "Jenis SP tidak boleh kosong"
  validates_presence_of :occurence_date, :message => "Tanggal kejadian tidak boleh kosong"
  validates_presence_of :person_id, :message => "Nama karyawan tidak boleh kosong / tidak terdaftar"
  validates_presence_of :active_until, :message => "Tanggal berlaku sampai tidak boleh kosong"
  attr_accessor :person_name, :pers_id
  named_scope :by_company, lambda {|val| {:conditions => "violations.company_id = #{val}"}}
  validate :valid_year?

  def valid_year?
    unless (occurence_date < active_until)
      errors.add(:occurence_date, "invalid")
      errors.add(:active_until, "invalid")
    end if !occurence_date.blank? && !active_until.blank?
  end

  def self.search_filter(f)
    return get_str_kondisi(f)
    #kond = get_str_kondisi(f)
    #violation = Violation.all(:conditions => kond)
    #return violation
  end

  def self.get_str_kondisi(f)
    kond = ""
    kond << get_person_kond(f)
    unless f[:violation_category].blank?
      kond << " and " unless kond.blank?
      kond << " violation_category = '#{f[:violation_category]}'"
    end
    unless f[:occurence_date].blank?
      kond << " and " unless kond.blank?
      kond << " occurence_date = '#{Person.format_date(f[:occurence_date])}'"
    end
    unless f[:active_until].blank?
      kond << " and " unless kond.blank?
      kond << " active_until <= '#{Person.format_date(f[:active_until])}'"
    end
    unless f[:action_taken].blank?
      kond << " and " unless kond.blank?
      kond << " action_taken = '#{f[:action_taken]}'"
    end
    return kond
  end

  def self.get_person_kond(f)
    kond = ""
    person_kond = ""
    person_kond << get_employment_kond(f)
    unless f[:nama].blank?
      person_kond << " AND " unless person_kond.blank?
      person_kond << "CONCAT(people.FirstName,' ',people.LastName) like '%#{f[:nama]}%'"
    end
    person = Person.all(:conditions => person_kond)
    unless person.blank?
      person_ids = person.collect{|x| "#{x.id}"}.uniq
      kond = " person_id in ('#{person_ids.join("','")}')"
    else
      kond = " person_id is null"
    end
    return kond
  end

  def self.get_employment_kond(f)
    emp_kondisi = ""
    person_kond = ""
    unless f[:department_id].blank?
      emp_kondisi << " and "unless emp_kondisi.blank?
      emp_kondisi << "department_id = '#{f[:department_id]}'"
    end

    unless f[:division_id].blank?
      emp_kondisi << " and "unless emp_kondisi.blank?
      emp_kondisi << "work_division_id = '#{f[:division_id]}'"
    end

    unless emp_kondisi.blank?
      emp = Employment.find(:all, :conditions => emp_kondisi)
      emp_id = emp.collect{|x| "#{x.id}"}
      person_kond << " and " unless person_kond.blank?
      person_kond << "latest_employment_id in ('#{emp_id.join("','")}')"
    end
    return person_kond
  end

  def self.params_to_date(violation)
    violation.update(:occurence_date=> violation[:occurence_date]) unless violation[:occurence_date].blank?
    violation.update(:active_until=> violation[:active_until]) unless violation[:active_until].blank?
    return violation
  end

  def options
    {
      :level => ['SP1','SP2','SP3'],
      :tingkat => ['Ringan','Sedang','Berat']
    }
  end

  def self.get_chart_sp(p_sp, f)
    bulan = []
    warning = []
    sp1 = []
    sp2 = []
    sp3 = []
    tot_warning = 0
    tot_sp1 =0
    tot_sp2 =0
    tot_sp3 =0
    mulai = "01-01-#{f[:tahun]}".to_date
    selesai = mulai.end_of_year
    while mulai < selesai
      bulan << "#{mulai.strftime("%b")}"
      warning_1 = p_sp.collect{|x| "#{x.person_id}" if mulai.strftime("%m") == x.occurence_date.to_date.strftime('%m') && x.action_taken.downcase == "warning"}
      sp_1 = p_sp.collect{|x| "#{x.person_id}" if mulai.strftime("%m") == x.occurence_date.to_date.strftime('%m') && x.action_taken.downcase == "sp1"}
      sp_2 = p_sp.collect{|x| "#{x.person_id}" if mulai.strftime("%m") == x.occurence_date.to_date.strftime('%m') && x.action_taken.downcase == "sp2"}
      sp_3 = p_sp.collect{|x| "#{x.person_id}" if mulai.strftime("%m") == x.occurence_date.to_date.strftime('%m') && x.action_taken.downcase == "sp3"}
      warning << warning_1.compact.uniq.count
      sp1 << sp_1.compact.uniq.count
      sp2 << sp_2.compact.uniq.count
      sp3 << sp_3.compact.uniq.count
      tot_warning += warning_1.compact.uniq.count
      tot_sp1 += sp_1.compact.uniq.count
      tot_sp2 += sp_2.compact.uniq.count
      tot_sp3 += sp_3.compact.uniq.count
      mulai = (mulai+1.month)
    end
    is_warning_nil = Employment.if_all_zero(warning)
    is_sp1_nil = Employment.if_all_zero(sp1)
    is_sp2_nil = Employment.if_all_zero(sp2)
    is_sp3_nil = Employment.if_all_zero(sp3)
    return {:bulan => bulan, :warning => warning, :sp1 => sp1, :sp2 => sp2, :sp3 => sp3,:is_warning_nil=> is_warning_nil, :is_sp1_nil => is_sp1_nil, :is_sp2_nil => is_sp2_nil, :is_sp3_nil => is_sp3_nil}
  end
end
