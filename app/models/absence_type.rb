class AbsenceType < ActiveRecord::Base
  has_many :absences
  validates_presence_of :absence_type_name, :message =>'Nama jenis tidak masuk  harus ada'
  validates_presence_of :absence_type_code, :message =>'Code jenis tidak masuk  harus ada'
  validates_numericality_of :quota, :message => "Quota harus berupa angka"
  validates_uniqueness_of :type_id, :scope => :company_id
  before_destroy :validate_all_relationships
  attr_protected :company_id, :absence_type_name

  def self.initializer(company_id)
    absence_types = self.find(:all, :conditions => { :company_id => company_id })
    if absence_types.blank?
      create_initial_data(company_id)
    end
  end
  
  def self.create_initial_data(company_id)
    ijin = AbsenceType.new(:type_id => 1, :quota => 0, :absence_type_code => "I", :count_as_leave => false, :is_salary_paid => false)
    ijin.company_id = company_id
    ijin.absence_type_name = 'Ijin'
    ijin.save
    cuti = AbsenceType.create(:type_id => 2, :quota => 0, :absence_type_code => "C", :count_as_leave => true, :is_salary_paid => true)
    cuti.company_id = company_id
    cuti.absence_type_name = 'Cuti'
    cuti.save
    sakit = AbsenceType.create(:type_id => 3, :quota => 0, :absence_type_code => "S", :count_as_leave => false, :is_salary_paid => false)
    sakit.company_id = company_id
    sakit.absence_type_name = 'Sakit'
    sakit.save
    mangkir = AbsenceType.create(:type_id => 4, :quota => 0, :absence_type_code => "A", :count_as_leave => false, :is_salary_paid => false)
    mangkir.company_id = company_id
    mangkir.absence_type_name = 'Mangkir'
    mangkir.save
    ck = AbsenceType.create(:type_id => 5, :quota => 0, :absence_type_code => "CK", :count_as_leave => true, :is_salary_paid => true)
    ck.company_id = company_id
    ck.absence_type_name = 'Cuti Khusus'
    ck.save
    ch = AbsenceType.create(:type_id => 6, :quota => 0, :absence_type_code => "CH", :count_as_leave => true, :is_salary_paid => true)
    ch.company_id = company_id
    ch.absence_type_name = 'Cuti Melahirkan'
    ch.save
    kecelakaan = AbsenceType.create(:type_id => 7, :quota => 0, :absence_type_code => "K", :count_as_leave => true, :is_salary_paid => true)
    kecelakaan.company_id = company_id
    kecelakaan.absence_type_name = 'Sakit Kecelakaan'
    kecelakaan.save
  end

  private

  def validate_all_relationships
    unless self.absences.empty?
      self.errors.add_to_base "Tidak dapat di hapus karena masih memiliki data absensi"
      false
    end
  end

end


# == Schema Information
#
# Table name: absence_types
#
#  id                :integer(4)      not null, primary key
#  absence_type_name :string(255)
#  is_salary_paid    :boolean(1)
#  created_at        :datetime
#  updated_at        :datetime
#  absence_type_code :string(255)
#  company_id        :integer(4)
#  type_id           :integer(4)
#  quota             :integer(4)
#  replaceable       :boolean(1)
#  count_as_leave    :boolean(1)
#

