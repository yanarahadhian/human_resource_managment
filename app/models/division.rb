# == Schema Information
#
# Table name: divisions
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  holding_company_id :integer(4)
#  company_id         :integer(4)
#  department_id      :integer(4)
#  division_code      :string(255)
#

class Division < ActiveRecord::Base
  belongs_to :department
  attr_protected :company_id
  validates_presence_of :name, :message => "Nama bagian tidak boleh kosong"
  validates_presence_of :division_code, :message => "Kode bagian tidak boleh kosong"
  validates_presence_of :department_id, :message => "Department tidak boleh kosong"
  validates_uniqueness_of :division_code, :message => "Kode ini sudah digunakan oleh division lain"
  has_many :work_groups, :dependent => :nullify
  has_many :employments, :foreign_key => "work_division_id"
  has_one :position
  has_many :employee_shifts

  before_destroy :validate_all_relationships

  named_scope :by_company, lambda {|val| {:conditions => "company_id = #{val}", :order => "name ASC"}}

  def self.find_condition_filter(company_id, f)
    statement = ""
    kondisi = []
    kondisi << statement
    division_id_by_jumlah_karyawan = get_division_id_by_jumlah_karyawan(company_id, f[:ket_jumlah],f[:jumlah_karyawan],f[:awal],f[:akhir])
    unless division_id_by_jumlah_karyawan.blank?
      statement << "id in (?)"
      kondisi << division_id_by_jumlah_karyawan
    end
    unless f[:nama].blank?
      statement << " AND " unless statement.blank?
      statement << "name like ?"
      kondisi << "%#{f[:nama]}%"
    end
    kondisi
  end

  def self.get_division_id_by_jumlah_karyawan(company_id, ket_jumlah, jml, awal, akhir)
    #jika minimal ato maksimal
    division_ids = Division.by_company(company_id).collect(&:id)
    case (ket_jumlah.to_i)
    when 1
      division_ids = Division.by_company(company_id).find_all{|x| x.personel_count >= jml.to_i}.collect(&:id)
    when 2
      division_ids = Division.by_company(company_id).find_all{|x| x.personel_count <= jml.to_i}.collect(&:id)
    when 3
      if !awal.blank? && !akhir.blank?
        division_ids = Division.by_company(company_id).find_all{|x| x.personel_count >= awal.to_i && x.personel_count <= akhir.to_i}.collect(&:id)
      elsif akhir.blank?
        division_ids = Division.by_company(company_id).find_all{|x| x.personel_count >= awal.to_i}.collect(&:id)
      elsif awal.blank?
        division_ids = Division.by_company(company_id).find_all{|x| x.personel_count <= akhir.to_i}.collect(&:id)
      end
    end unless ket_jumlah.blank?
    division_ids
  end

  def groups_count
    self.work_groups.count
  end

  def personel
    personel = []
    unless self.employments.blank?
      personel = self.employments.find_all{|emp| emp.current_employment?}.collect{|emp| emp.current_employment_people}.uniq
    end
    return personel
  end

  def division_head_name
    head = Employment.current_head(self.id, false )
    if head
      head.person.full_name
    end
  end

  def personel_count
    self.personel.count
  end

  def self.check_data(company_id,holding_id,divisions)
    check = self.find(:first,:conditions => ["company_id = ? and holding_company_id =?",company_id,holding_id])
    if check.blank?
      puts "    4. Running Division"
      divisions.each do |d|
        department = Department.find_by_company_id_and_department_code(company_id,d[0])
        d[1].each do |v|
          data = self.new({:name => v[1],:division_code => v[0],:holding_company_id =>holding_id,:department_id => department.id })
          data.company_id = company_id
          data.save
        end
      end
    end
  end

  private

  def validate_all_relationships
    used = false
    if self.employments.blank?
      used = true
    end
    if used
      errors.add :base, "Tidak bisa hapus bagian karena sudah dipakai di table lain"
      return false
    end
  end
end