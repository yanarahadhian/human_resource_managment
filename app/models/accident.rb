# == Schema Information
#
# Table name: accidents
#
#  id                        :integer(4)      not null, primary key
#  accident_location         :string(255)
#  accident_date             :date
#  causes                    :string(255)
#  accident_description      :text
#  action_taken              :string(255)
#  accident_category         :string(255)
#  person_id                 :integer(4)
#  created_at                :datetime
#  updated_at                :datetime
#  accident_person_in_charge :string(255)
#  company_id                :integer(4)
#

class Accident < ActiveRecord::Base

  belongs_to :person, :foreign_key => "person_id"

  validates_presence_of :accident_location, :message => "Lokasi tidak boleh kosong"
  validates_presence_of :person_id, :message => "Nama karyawan tidak boleh kosong/ tidak terdaftar"
  validates_presence_of :accident_date, :message => "Tanggal kecelakaan tidak boleh kosong"
  validates_presence_of :accident_person_in_charge, :message => "Penanggung jawab tidak boleh kosong"
  validates_presence_of :accident_category, :message => "Kategori Kecelakaan tidak boleh kosong"
  attr_accessor :person_name, :position_name, :pers_id

  named_scope :by_company, lambda {|val| {:conditions => "accidents.company_id = #{val}"}}

  def options
    { :category => ['Ringan','Sedang', 'Berat'] }
  end

  def self.param_date_to_str(kejadian)
    unless kejadian[:accident_date].blank?
      return kejadian.update(:accident_date => kejadian[:accident_date].to_date)
    else
      return kejadian
    end
  end

  def self.search_filter(f)
    return get_str_kondisi(f)
    #kond = get_str_kondisi(f)
    #violation = Accident.all(:conditions => kond)
    #return violation
  end

  def self.get_str_kondisi(f)
    kond = ""
    kond += get_person_kond(f)
    #"filter"=>{"accident_person_in_charge"=>"asa", "division_id"=>"", "nama"=>"vita", "accident_date"=>"2011-06-08"}
    unless f[:accident_person_in_charge].blank?
      kond += " and " unless kond.blank?
      kond += "accidents.accident_person_in_charge like('%#{f[:accident_person_in_charge]}%')"
    end
    unless f[:accident_date].blank?
      kond += " and " unless kond.blank?
      kond += "accidents.accident_date= '#{Person.format_date(f[:accident_date])}'"
    end
    unless f[:accident_category].blank?
      kond += " and " unless kond.blank?
      kond += "accidents.accident_category= '#{f[:accident_category]}'"
    end
    return kond
  end

  def self.get_person_kond(f)
    kond = ""
    person_kond = get_str_employment(f)
    person = Person.all(:conditions => person_kond)
    unless f[:nama].blank?
      person = person.find_all{|x| x.full_name.downcase.include?(f[:nama].downcase)}
    end

    unless person.blank?
      person_ids = person.collect {|x| "#{x.id}"}
      kond += " and " unless kond.blank?
      kond += " person_id in ('#{person_ids.join("','")}')"
    end
    return kond
  end

  def self.get_str_employment(f)
    person_kond = ""
    emp_kondisi = ""
    unless f[:division_id].blank?
      emp_kondisi << " and "unless emp_kondisi.blank?
      emp_kondisi << "work_division_id = '#{f[:division_id]}'"
    end

    unless f[:department_id].blank?
      emp_kondisi << " and "unless emp_kondisi.blank?
      emp_kondisi << "department_id = '#{f[:department_id]}'"
    end

    unless emp_kondisi.blank?
      emp = Employment.find(:all, :conditions => emp_kondisi)
      emp_id = emp.collect{|x| "#{x.id}"}
      person_kond << " and " unless person_kond.blank?
      person_kond << "latest_employment_id in ('#{emp_id.join("','")}')"
    end
    return person_kond
  end


  def self.get_chart_accident(p_accident, f)
    bulan = []
    value = []
    if f[:bulan].blank?
      mulai = "01-01-#{f[:tahun]}".to_date
      selesai = mulai.end_of_year
      while mulai < selesai
        bulan << "#{mulai.strftime("%b")}"
        ac_value = p_accident.collect {|x| "#{x.person_id}" if mulai.strftime("%m") == x.accident_date.to_date.strftime('%m')}
        value << ac_value.compact.uniq.count
        mulai = (mulai+1.month)
      end
    else
      mulai = "01-#{f[:bulan]}-#{f[:tahun]}".to_date
      bulan = ["Ringan","Sedang","Berat"]
      bulan.each do |m|
        acc_value = p_accident.collect {|x| "#{x.person_id}" if "#{f[:bulan]}-#{f[:tahun]}" == x.accident_date.to_date.strftime('%m-%Y') &&  m==x.accident_category }
        value << acc_value.compact.uniq.count
      end
    end
    is_accident_nil = Employment.if_all_zero(value)
    return {:bulan => bulan, :value => value, :is_nil => is_accident_nil}
  end
end

