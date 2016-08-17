# == Schema Information
#
# Table name: departments
#
#  id              :integer(4)      not null, primary key
#  company_id      :integer(4)
#  department_name :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  department_code :string(255)
#

class Department < ActiveRecord::Base
  has_many :divisions
  has_many :employments
  attr_protected :company_id
  # has_many :honors, :dependent => :destroy
  validates_presence_of :department_code, :message => "Kode departemen tidak boleh kosong"
  validates_presence_of :department_name, :message => "Nama departemen tidak boleh kosong"
  validates_uniqueness_of :department_code, :scope => :company_id, :message => "Kode ini sudah digunakan oleh departemen lain"
  named_scope :by_company, lambda {|val| {:conditions => "company_id = #{val}", :order => "department_name ASC"}}

  before_destroy :validate_all_relationships

  def self.find_condition_filter(company_id, f)
    statement = ""
    kondisi = []
    kondisi << statement
    department_id_by_jumlah_karyawan = get_department_id_by_jumlah_karyawan(company_id, f[:ket_jumlah],f[:jumlah_karyawan],f[:awal],f[:akhir])
    if department_id_by_jumlah_karyawan
      statement << "id in (?)"
      kondisi << department_id_by_jumlah_karyawan
    end
    unless f[:nama].blank?
      statement << " AND department_name like ? "
      kondisi << "%#{f[:nama]}%"
    end
    return kondisi
  end

  def self.get_department_id_by_jumlah_karyawan(company_id, ket_jumlah, jml, awal, akhir)
    #jika minimal ato maksimal
    department_ids = Department.by_company(company_id).collect(&:id)
    case (ket_jumlah.to_i)
    when 1
      department_ids = Department.by_company(company_id).find_all{|x| x.personel_count >= jml.to_i}.collect(&:id)
    when 2
      department_ids = Department.by_company(company_id).find_all{|x| x.personel_count <= jml.to_i}.collect(&:id)
    when 3
      if !awal.blank? && !akhir.blank?
        department_ids = Department.by_company(company_id).find_all{|x| x.personel_count >= awal.to_i && x.personel_count <= akhir.to_i}.collect(&:id)
      elsif akhir.blank?
        department_ids = Department.by_company(company_id).find_all{|x| x.personel_count >= awal.to_i}.collect(&:id)
      elsif awal.blank?
        department_ids = Department.by_company(company_id).find_all{|x| x.personel_count <= akhir.to_i}.collect(&:id)
      end
    end unless ket_jumlah.blank?
    department_ids
  end


  def personel
    personel = []
    unless self.employments.blank?
      personel = self.employments.find_all{|emp| emp.current_employment?}.collect{|emp| emp.current_employment_people}.uniq
    end
    return personel
  end

  def personel_count
    self.personel.count
  end

  def division_count
    self.divisions.count
  end

  def department_head_name
    head = Employment.current_head(self.id)
    if head
      head.person.full_name
    end
  end

  def validate_all_relationships
    return false unless self.divisions.empty?
    return false unless self.employments.empty?
  end

  def self.check_data(company_id,departments)
    if self.find_by_company_id(company_id).blank?
      puts "    RUNNING DEPARTEMENT"
      departments.each do |d|
        data = self.new({:department_name => d[1] ,:department_code => d[0]})
        data.company_id = company_id
        data.save 
      end
    end
  end
  

end


