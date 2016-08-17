# == Schema Information
#
# Table name: employments
#
#  id                     :integer(4)      not null, primary key
#  person_id              :integer(4)
#  department_id          :integer(4)
#  employment_type_id     :integer(4)
#  work_group_id          :integer(4)
#  position_id            :integer(4)
#  work_division_id       :integer(4)
#  head_division          :boolean(1)
#  head_department        :boolean(1)
#  employment_start       :date
#  employment_end         :date
#  work_assigned          :string(255)
#  change_from_before     :string(255)
#  reason_for_change      :text
#  previous_employment_id :integer(4)
#  created_at             :datetime
#  updated_at             :datetime
#  shift_option_type      :string(255)
#  type_employment        :string(255)
#

class Employment < ActiveRecord::Base
  belongs_to :company
  belongs_to :department
  belongs_to :division, :foreign_key => "work_division_id"
  belongs_to :person
  belongs_to :position
  belongs_to :work_group
  belongs_to :shift
  belongs_to :employment_type
  #after_update :save_previous
  attr_accessor :employment_type_check
  validates_presence_of :employment_start, :message => "Tanggal mulai tidak boleh kosong"
  validate :valid_year?
  named_scope :by_company, lambda {|val| {:conditions => "company_id = #{val}"}}
  attr_accessor :company_id

  def self.search_filter(f)
    emp_kondisi = ""

    person = Person.all(:conditions => emp_kondisi)

    return person
  end

  def valid_year?
    if (!employment_start.blank? &&  !employment_end.blank?)
      if (employment_start > employment_end)
        self.errors.add(:employment_start, "Tanggal awal is invalid")
        self.errors.add(:employment_end, "Tanggal selesai is invalid")
      end
    end
  end

  def current_division
    e = self.division
    if e.blank?
      return Division.new(:name => 'Belum ada divisi')
    else
     return Division.find(work_division_id) unless work_division_id.blank?
    end
  end


  def self.emp_sort(person_id)
    sorted = self.find_by_sql("select if ( employment_end IS NULL, 1, 0 ) as myOrder,id,employment_start,employment_end,reason_for_change,shift from employments where person_id = '"+person_id.to_s+"' order by myOrder DESC, employment_start DESC, created_at DESC")
    return sorted
  end

  def current_employment?(date = Date.today)
    person = self.person
    fixed = self.employment_end.blank? && self.employment_start <= date
    current = self.employment_end >= date && self.employment_start <= date unless fixed || self.employment_end.blank?
    unless person.blank?
      return fixed || current
    else
      return false
    end
    return false
  end

  def current_employment_people
    if self.current_employment?
      return self.person
    end
  end

  def self.current_head(id, dept = true)
    if dept
      heads = self.find(:all, :conditions => {:head_department => true, :department_id => id }, :order => "created_at DESC")
    else
      heads = self.find(:all, :conditions => {:head_division => true, :work_division_id => id }, :order => "created_at DESC")
    end
    return heads.first
  end

  def shift_group_option?
    self.shift_option_type == 'ShiftGroupOption'
  end

  def shift_normal_option?
    self.shift_option_type == 'ShiftNormalOption'
  end

  def shift_option_name
    if shift_option.blank?
      return nil
    else
      return shift_option.name
    end
  end

  def self.param_str_to_date(employment)
    if employment[:change_from_before] == "terminasi"
      employment.update(:employment_end=> employment[:created_at])
      employment.update(:employment_start=> employment[:created_at])
    else
      unless employment[:employment_start].blank?
        employment.update(:employment_start=> employment[:employment_start])
      end
      unless employment[:employment_end].blank?
        employment.update(:employment_end=> employment[:employment_end])
      end
    end
    return employment
  end

  def perubahan
    ['masuk kerja','mutasi','promosi','demosi']
  end

  def self.change_hash_to_array(pworkcontract)
    workcontract = []
    pworkcontract[:contract_type_id].each_key do |k|
      start = ""
      selesai = ""
      id = ""
      start = pworkcontract[:contract_start][k].to_date unless pworkcontract[:contract_start][k].blank?
      selesai = pworkcontract[:contract_end][k].to_date unless pworkcontract[:contract_end][k].blank?
      id = pworkcontract[:id][k] unless pworkcontract[:id].blank?
      data = {:contract_type_id => pworkcontract[:contract_type_id][k],
              :contract_start => start,
              :contract_end => selesai,
              :id => id
              }
      workcontract << data
    end
    return workcontract
  end

  def self.get_range_month(emp, f)
    bulan = []
    keluar = []
    masuk = []
    if f[:bulan].blank? && !f[:tahun].blank?
      mulai = "01-01-#{f[:tahun]}".to_date
      selesai = mulai.end_of_year
      while mulai < selesai
        mutasi_masuk = emp.collect {|x| "#{x.person_id}" if mulai.strftime("%m") == x.employment_start.to_date.strftime('%m') && x.change_from_before.downcase=="masuk kerja"}
        mutasi_keluar = emp.collect {|x| "#{x.person_id}" if mulai.strftime("%m") == x.employment_start.to_date.strftime('%m') && x.change_from_before.downcase=="terminasi"}
        bulan << "#{mulai.strftime("%b")}"
        masuk << mutasi_masuk.compact.uniq.count
        keluar << mutasi_keluar.compact.uniq.count
        mulai = (mulai+1.month)
      end
    else
      mutasi_masuk = emp.collect {|x| "#{x.person_id}" if f[:bulan] == x.employment_start.to_date.strftime('%m') && x.change_from_before.downcase=="masuk kerja"}
      mutasi_keluar = emp.collect {|x| "#{x.person_id}" if f[:bulan] == x.employment_start.to_date.strftime('%m') && x.change_from_before.downcase=="terminasi"}
      bulan << "#{f[:bulan]}"
      masuk << mutasi_masuk.compact.uniq.count
      keluar << mutasi_keluar.compact.uniq.count
    end
    is_nil = is_keluar_masuk_nil(keluar, masuk)
    return {:bulan => bulan, :masuk=> masuk, :keluar => keluar, :is_nil => is_nil}
  end

   def self.get_chart_formasi(ids_person_by_company, is_chart = true)
    cond = "id in (#{ids_person_by_company.join(",")})"
    person = Person.all(:conditions => cond)
    gender = []
    gen_value = []
    person_id = []
    ["pria","wanita"].each do |g|
      gender << g
      val = person.collect {|x| x.id if x.gender.downcase== g}
      gen_value << val.compact.uniq.count
      person_id << Person.all(:conditions => "id in (#{val.compact.uniq.join(",")})", :order => "firstname") unless is_chart
    end
    is_gen_nil = if_all_zero(gen_value)
    if is_chart
      return {:is_gen_nil=> is_gen_nil, :gender => gender, :gen_value => gen_value}
    else
      return {:person => person_id}
    end
  end

  def self.get_chart_formasi_jabatan(emp,company_id)
    proses_position = formasi_by_position(company_id, emp)
    position = proses_position[:position]
    pos_value = proses_position[:pos_value]
    is_pos_nil = if_all_zero(pos_value)
    return {:position => position,
            :pos_value => pos_value,
            :is_pos_nil => is_pos_nil}
  end

  def self.get_chart_formasi_departemen(emp,company_id)
    proses_department = formasi_by_department(company_id, emp)
    department = proses_department[:department]
    dept_value = proses_department[:dept_value]
    is_dept_nil = if_all_zero(dept_value)
    return {:department => department,
            :dept_value => dept_value,
            :is_dept_nil => is_dept_nil}
  end

  def self.get_chart_formasi_bagian(emp,company_id)
    proses_div = formasi_by_division(company_id, emp)
    division = proses_div[:division]
    div_value = proses_div[:div_value]
    is_div_nil = if_all_zero(div_value)
    return {:division => division,
            :div_value => div_value,
            :is_div_nil => is_div_nil}
  end

  def self.formasi_by_position(company_id, emp, is_chart = true)
    position = []
    pos_value = []
    person = []
    Position.by_company(company_id).all.each do |d|
      val = emp.collect {|x| "#{x.person_id}" if x.position_id == d.id}
      unless val.compact.uniq.count==0
        position << d.position_name
        pos_value << val.compact.uniq.count
        person << Person.all(:conditions => "id in (#{val.compact.uniq.join(",")})", :order => "firstname") unless is_chart
      end
    end
    if is_chart
      return {:position => position, :pos_value => pos_value}
    else
      return {:person => person}
    end
  end

  def self.formasi_by_department(company_id, emp, is_chart = true)
    department = []
    dept_value = []
    person = []
    Department.by_company(company_id).all.each do |d|
      val = emp.collect {|x| x.person_id if x.department_id == d.id}
      unless val.compact.uniq.count==0
        department << d.department_name
        dept_value << val.compact.uniq.count
        person << Person.all(:conditions => "id in (#{val.compact.uniq.join(",")})", :order => "firstname") unless is_chart
      end
    end
    if is_chart
      return {:department => department, :dept_value => dept_value}
    else
      return {:person => person}
    end
  end

  def self.formasi_by_division(company_id, emp, is_chart = true)
    division = []
    div_value = []
    person = []
    Division.by_company(company_id).all.each do |d|
      val = emp.collect {|x| "#{x.person_id}" if x.work_division_id == d.id}
      unless val.compact.uniq.count==0
        division << d.name
        div_value << val.compact.uniq.count
        person << Person.all(:conditions => "id in (#{val.compact.uniq.join(",")})", :order => "firstname") unless is_chart
      end
    end
    if is_chart
      return {:division => division, :div_value => div_value}
    else
      return {:person => person}
    end
  end

  def self.set_percentage(value, tot_value)
    data = []
    percen = []
    value.each do |val|
      nilai = 0
      nilai = (val*100)/tot_value if val> 0
      data << nilai
      percen << "#{nilai}%"
    end
    return {:data => data, :percen => percen}
  end

  def self.is_keluar_masuk_nil(keluar, masuk)
    is_nil =false
    is_masuk_nil = masuk.collect {|x| x if x > 0}.compact.blank?
    is_keluar_nil = keluar.collect {|x| x if x > 0}.compact.blank?
    if is_masuk_nil && is_keluar_nil
      is_nil = true
    end
    return is_nil
  end

  def self.if_all_zero(data)
    is_nil = false
    is_nil = data.collect {|x| x if x > 0}.compact.blank?
    return is_nil
  end

  def set_previus_employment
    p = self.person
    #apakah yang dihapus adalah latest
    if p.latest_employment_id == self.id
      unless self.previous_employment_id.blank?
        p.latest_employment_id = self.previous_employment_id
      else
        p.latest_employment_id = nil
      end
      p.save
    else
      unless self.previous_employment_id.blank?
        next_employment = Employment.find_by_previous_employment_id(self.id)
        unless next_employment.blank?
          next_employment.previous_employment_id = self.previous_employment_id
          next_employment.save
        end
      end
    end
  end

  #params['value'], params['division']
  def self.person_by_work_group(param, company_id)
    value = []
    key = []
    unless param['value'].blank?
      key << "work_group_id = ?"
      value << param['value']
    end
    unless param['division'].blank?
      key << "work_division_id = ?"
      value << param['division']
    end
    emp_person_id = nil
    unless key.blank?
      if key.count > 1
        emp_person_id = self.find(:all, :select=> "person_id",:conditions => ["#{key.join(" AND ")}", value.first, value.last])
      else
        emp_person_id = self.find(:all, :select=> "person_id",:conditions => ["#{key.join(" AND ")}", value.first])
      end
    end
    unless emp_person_id.blank?
      person_id = emp_person_id.collect{|x| x.person_id}.compact.uniq
      emp_kond = "(employments.change_from_before!='terminasi' OR employments.change_from_before is NULL) AND (people.latest_employment_id=employments.id) AND people.id in (#{person_id.join(",")}) AND people.company_id=#{company_id}"
      person = Person.all(:include => [:employments], :conditions => emp_kond)
      return person
    end
    return nil
  end
end