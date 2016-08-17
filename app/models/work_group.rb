# == Schema Information
#
# Table name: work_groups
#
#  id              :integer(4)      not null, primary key
#  company_id      :integer(4)
#  work_group_name :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  division_id     :integer(4)
#

class WorkGroup < ActiveRecord::Base
  belongs_to :division
  has_many :employments
  has_many :employee_shifts
  attr_protected :company_id
  validates_presence_of :work_group_name, :message=> "Nama work group tidak boleh kosong"
  validates_presence_of :division_id, :message=> "Divisi tidak boleh kosong"

  before_destroy :validate_all_relationships

  named_scope :by_company, lambda {|val| {:conditions => "company_id = #{val}", :order => "work_group_name ASC"}}

  def self.find_condition_filter(company_id, f)
    statement = ""
    kondisi = []
    kondisi << statement
    division_id_by_jumlah_karyawan = get_work_group_id_by_jumlah_karyawan(company_id, f[:ket_jumlah],f[:jumlah_karyawan],f[:awal],f[:akhir])
    unless division_id_by_jumlah_karyawan.blank?
      statement << "id in (?)"
      kondisi << division_id_by_jumlah_karyawan
    end
    unless f[:nama].blank?
      statement << " AND " unless statement.blank?
      statement << "work_group_name like ?"
      kondisi << "%#{f[:nama]}%"
    end
    kondisi
  end

  def self.get_work_group_id_by_jumlah_karyawan(company_id, ket_jumlah, jml, awal, akhir)
    work_group_ids = WorkGroup.by_company(company_id).collect(&:id)
    case (ket_jumlah.to_i)
    when 1
      work_group_ids = WorkGroup.by_company(company_id).find_all{|x| x.personel_count >= jml.to_i}.collect(&:id)
    when 2
      work_group_ids = WorkGroup.by_company(company_id).find_all{|x| x.personel_count <= jml.to_i}.collect(&:id)
    when 3
      if !awal.blank? && !akhir.blank?
        work_group_ids = WorkGroup.by_company(company_id).find_all{|x| x.personel_count >= awal.to_i && x.personel_count <= akhir.to_i}.collect(&:id)
      elsif akhir.blank?
        work_group_ids = WorkGroup.by_company(company_id).find_all{|x| x.personel_count >= awal.to_i}.collect(&:id)
      elsif awal.blank?
        work_group_ids = WorkGroup.by_company(company_id).find_all{|x| x.personel_count <= akhir.to_i}.collect(&:id)
      end
    end unless ket_jumlah.blank?
    work_group_ids
  end

  def personel
    personel = []
    unless self.employments.blank?
      personel = self.employments.find_all{|emp| emp.current_employment?}.collect{|emp| emp.current_employment_people}.uniq
    end
    return personel
  end

  def position_count
    positions = self.employments.find(:all, :select => "DISTINCT position_id" )
    return positions.count
  end

  def personel_count
    self.personel.count
  end

  def self.check_data(holding_id,current_company_id,work_group)
    check = self.find(:first,:conditions => ["company_id = ?",current_company_id])
    if check.blank?
      puts "    5. Running Work Group"
      division_code = Array.new()
      work_group.each{|key,value| division_code << key}
      Division.find(:all,:conditions => ["division_code in (?) and company_id = ? and holding_company_id = ?",division_code,current_company_id,holding_id]).each do |d|
        data = self.new({:work_group_name => work_group["#{d.division_code}"] ,  :division_id => d.id })
        data.company_id = current_company_id
        data.save
      end
    end
  end

  private

  def validate_all_relationships
    return false unless self.employments.empty?
  end
end