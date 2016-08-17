# == Schema Information
#
# Table name: premiums
#
#  id                       :integer(4)      not null, primary key
#  premium_name             :string(255)
#  calculated_automatically :boolean(1)
#  created_at               :datetime
#  updated_at               :datetime
#  company_id               :integer(4)
#  calculated_on_overtime   :integer(4)
#  calculated_on_salary_cut :integer(4)
#  count_daily              :boolean(1)      default(FALSE)
#

class Premium < ActiveRecord::Base
  has_many :premium_in_companies
  has_many :premium_in_honors
  has_many :premium_master_datas, :foreign_key=> :premiums_in_company_id, :dependent => :destroy
  validates_presence_of :premium_name
  validates_uniqueness_of :premium_name, :case_sensitive => false, :scope => :company_id

  attr_protected :company_id

  def value(person, month, year)
    case self.premium_name
      when 'Premi Masa Kerja'
        value_length_of_service_premium(person, month, year)
      when 'Premi Jabatan'
        value_position_premium(person, month, year)
      when 'Premi Hadir Bulanan'
        value_attendance_premium(person, month, year)
      when 'Premi Bersyarat'
        value_conditional_premium(person, month, year)
    end
  end

  private

  # Premi Masa Kerja
  def value_length_of_service_premium(person, month, year)
    rate = 0
    works_days = 0

    if person.current_status.contract_type.contract_type_name == 'Tetap Harian'
      # Get total length of person services in company
      length_of_service = (person.total_length_of_service(person).to_i)/31536000
      # Get total works days of person
      if length_of_service >= 1
        works_days = person.presences.total_work_days(month,year)[:days]
      else
        works_days = 0
      end

      # Get rate of value_length_of_service
      if length_of_service >= 1 && length_of_service <= 3
        rate = 400
      elsif length_of_service >= 3 && length_of_service <= 5
        rate = 600
      elsif length_of_service >= 5 && length_of_service <= 7
        rate = 800
      elsif length_of_service >= 7 && length_of_service <= 9
        rate = 1000
      elsif length_of_service >= 9 && length_of_service <= 11
        rate = 1200
      elsif length_of_service > 14
        rate = 1400
      else
        rate = 0
      end

    end
      return rate * works_days
  end

  # Premi Jabatan
  def value_position_premium(person, month, year)
    value_position_premium = 0
    if person.current_status.contract_type.contract_type_name == 'Tetap Harian' || person.current_status.contract_type.contract_type_name == 'Tetap Bulanan'  && !person.current_position.blank?
      position = person.current_position
      case position
        when 'Jr. Wakaru'
          value_position_premium = 20000
        when 'Wakaru'
          value_position_premium = 35000
        when 'Karu'
          value_position_premium = 50000
        when 'Wadanru'
          value_position_premium = 50000
        when 'Anggota'
          value_position_premium = 20000
        when 'Sopir'
          value_position_premium = 50000
        when 'Kenek'
          value_position_premium = 25000
      end
    end
    return value_position_premium
  end

  # Premi Hadir Bulanan
  def value_attendance_premium(person, month, year)
    total_length_of_service = person.total_length_of_service(person).to_i/31536000*12
    value = 0
    if total_length_of_service > 3
      position = person.current_position
      case position
        when 'Jr. Wakaru'
          premium_value = 33000
        when 'Wakaru'
          premium_value = 39000
        when 'Karu'
          premium_value = 45000
        when 'Wadanru'
          premium_value = 39000
        when 'Sopir'
          premium_value = 45000
        when 'Inspector 0'
          premium_value = 27000
        when 'Inspector 1'
          premium_value = 33000
        when 'Inspector 2'
          premium_value = 39000
        when 'Inspector 3'
          premium_value = 45000
        when 'Operator'
          premium_value = 27000
      end

      attendance_premium_cut = 0
      # Todo: Count attendance_premium_cuts
      # attendance_premium_cut = premium_value*1/3
      # attendance_premium_cut = premium_value*2/3
      # attendance_premium_cut = premium_value*3/3

      value = premium_value.to_f - attendance_premium_cut.to_f
    end
    return value
  end

  # Premi Bersyarat
  def value_conditional_premium(person, month, year)
    value = 0
    unless person.current_employment.department.blank?
      department = person.current_employment.department.department_name

      # Untuk department Inspecting
      if department == 'Inspecting'
        # Get position of person
        position = person.current_position
        case position
          when 'Inspector 0'
            value = 1500
          when 'Inspector 1'
            value = 2000
          when 'Inspector 2'
            value = 2500
          when 'Inspector 3'
            value = 3500
        end
      end
      # Untuk department Teknik Boiler
      if department == 'Teknik Boiler'
        value = 5000
      end
    end
    return value
  end

end

