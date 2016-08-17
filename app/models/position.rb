# == Schema Information
#
# Table name: positions
#
#  id            :integer(4)      not null, primary key
#  company_id    :integer(4)
#  position_name :string(255)
#  position_code :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class Position < ActiveRecord::Base
  has_many :employments
  attr_protected :company_id
  validates_presence_of :position_name, :message => "Nama posisi tidak boleh kosong"
  named_scope :by_company, lambda {|val| {:conditions => "company_id = #{val}", :order => "position_name ASC"}}
  # after_save :api_update_position

  before_destroy :validate_all_relationships

  def self.search(conditions, mins, maxs, limit=nil, offset=nil,  sort=nil )
    unless limit.nil? && offset.nil?
      positions = Position.all(:order => sort,
        :limit => limit,
        :offset => offset,
        :conditions => conditions)
    else
      positions = Position.all(:conditions => conditions)
    end

    if !mins.blank? && mins.to_i >= 0
      filtered_positions = []
      positions.each do |position|
        if position.personel_count >= mins.to_i
          filtered_positions << position
        end
      end
      positions = filtered_positions
    end

    if !maxs.blank? && maxs.to_i >= 0
      filtered_positions = []
      positions.each do |position|
        if position.personel_count <= maxs.to_i
          filtered_positions << position
        end
      end
      positions = filtered_positions
    end

    return positions
  end

  def self.find_condition_filter(company_id, f)
    statement = ""
    kondisi = []
    kondisi << statement
    position_id_by_jumlah_karyawan = get_position_id_by_jumlah_karyawan(company_id, f[:ket_jumlah],f[:jumlah_karyawan],f[:awal],f[:akhir])
    unless position_id_by_jumlah_karyawan.blank?
      statement << "id in (?)"
      kondisi << position_id_by_jumlah_karyawan
    end
    unless f[:nama].blank?
      statement << " AND " unless statement.blank?
      statement << "position_name like ?"
      kondisi << "%#{f[:nama]}%"
    end
    return kondisi
  end

  def self.get_position_id_by_jumlah_karyawan(company_id, ket_jumlah, jml, awal, akhir)
    position_ids = Position.by_company(company_id).collect(&:id)
    case (ket_jumlah.to_i)
    when 1
      position_ids = Position.by_company(company_id).find_all{|x| x.personel_count >= jml.to_i}.collect(&:id)
    when 2
      position_ids = Position.by_company(company_id).find_all{|x| x.personel_count <= jml.to_i}.collect(&:id)
    when 3
      if !awal.blank? && !akhir.blank?
        position_ids = Position.by_company(company_id).find_all{|x| x.personel_count >= awal.to_i && x.personel_count <= akhir.to_i}.collect(&:id)
      elsif akhir.blank?
        position_ids = Position.by_company(company_id).find_all{|x| x.personel_count >= awal.to_i}.collect(&:id)
      elsif awal.blank?
        position_ids = Position.by_company(company_id).find_all{|x| x.personel_count <= akhir.to_i}.collect(&:id)
      end
    end unless ket_jumlah.blank?
    position_ids
  end

  def personel
    personel = []
    unless self.employments.blank?
      personel = self.employments.find_all{|emp| emp.current_employment?}.collect{|emp| emp.current_employment_people}.uniq
#      self.employments.each do |emp|
#        if emp.current_employment?
#          person = emp.current_employment_people
#          personel << person if person.company_id ==  company_id
#        end
#      end
    end
    return personel
  end

  def personel_count
    self.personel.count
  end

  def self.check_data(company_id,positions)
    check = self.find_by_company_id(company_id)
    if check.blank?
      puts "    3. Running Positions"
      positions.each do |d|
        data = self.new({:position_name => d[1] ,:position_code => d[0]})
        data.company_id = company_id
        data.save 
      end
    end
  end

  private

  def validate_all_relationships
    return false unless self.employments.empty?
  end
end