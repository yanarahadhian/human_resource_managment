# == Schema Information
#
# Table name: shifts
#
#  id                :integer(4)      not null, primary key
#  company_id        :integer(4)
#  shift_name        :string(255)
#  monday_time_id    :integer(4)
#  tuesday_time_id   :integer(4)
#  wednesday_time_id :integer(4)
#  thursday_time_id  :integer(4)
#  friday_time_id    :integer(4)
#  saturday_time_id  :integer(4)
#  sunday_time_id    :integer(4)
#  shift_category    :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  total_hours       :integer(4)
#

class Shift < ActiveRecord::Base
  validates_presence_of :shift_name, :message =>'Nama shift tidak boleh kosong'
  validates_presence_of :shift_code, :message =>'Kode shift tidak boleh kosong'

  has_many :employee_shifts
  belongs_to :monday_time , :class_name => 'WorkTime' , :foreign_key => 'monday_time_id'
  belongs_to :tuesday_time, :class_name => "WorkTime", :foreign_key => "tuesday_time_id"
  belongs_to :wednesday_time, :class_name => "WorkTime", :foreign_key => "wednesday_time_id"
  belongs_to :thursday_time, :class_name => "WorkTime", :foreign_key => "thursday_time_id"
  belongs_to :friday_time, :class_name => "WorkTime", :foreign_key => "friday_time_id"
  belongs_to :saturday_time, :class_name => "WorkTime", :foreign_key => "saturday_time_id"
  belongs_to :sunday_time, :class_name => "WorkTime", :foreign_key => "sunday_time_id"
  named_scope :by_company, lambda {|val| {:conditions => "company_id = #{val}"}}

  before_destroy :validate_all_relationships
  attr_protected :company_id
  
  after_save :set_shift_on_hr_setting
  after_destroy :unset_shift_on_hr_setting

  def set_shift_on_hr_setting
    hr_setting = HrSetting.find_by_company_id(self.company_id)
    hr_setting.update_attributes(:shift_is_set => true) if !hr_setting.blank? && !hr_setting.shift_is_set
  end

  def unset_shift_on_hr_setting
    shift = Shift.find(:first, :select => 'id', :conditions=> "company_id = #{self.company_id}")
    if shift.blank?
      hr_setting = HrSetting.find_by_company_id(self.company_id)
      hr_setting.update_attributes(:shift_is_set => false) 
    end
  end

  def daily_schedule(date)
    schedule = case date.wday
            when 0 then self.sunday_time
            when 1 then self.monday_time
            when 2 then self.tuesday_time
            when 3 then self.wednesday_time
            when 4 then self.thursday_time
            when 5 then self.friday_time
            else self.saturday_time
    end
    return schedule
  end

  def self.calculate_length_in_hours(start_time, end_time, pbreak, pbreak_choice)
    length_in_hours = (((Time.parse(end_time)) - (Time.parse(start_time))))/3600
    if length_in_hours < 0
      length_in_hours = length_in_hours + 24
    end
    if pbreak_choice == 'per_day'
      break_length_in_minutes = pbreak.to_i
      break_per_hour = 0
      length_in_hours = length_in_hours - (break_length_in_minutes.to_f / 60)
    else
      break_length_in_minutes = 0
      break_per_hour = pbreak.to_i
      length_in_hours = length_in_hours - (break_per_hour.to_f / 60)
    end
    return {:break_length_in_minutes => break_length_in_minutes,
            :break_per_hour_in_minutes => break_per_hour,
            :length_in_hours => length_in_hours
            }
  end

  def self.get_id_work_time(work_time, i)
    if i == 1
      return work_time.monday_time_id
    elsif i == 2
      return  work_time.tuesday_time_id
    elsif i == 3
      return  work_time.wednesday_time_id
    elsif i == 4
      return  work_time.thursday_time_id
    elsif i == 5
      return  work_time.friday_time_id
    elsif i == 6
      return  work_time.saturday_time_id
    elsif i == 7
      return  work_time.sunday_time_id
    end
  end

  def self.set_worktime_id_to_shift(shift,id, j)
    if j == 1
      shift.monday_time_id = id
    elsif j == 2
      shift.tuesday_time_id = id
    elsif j == 3
      shift.wednesday_time_id = id
    elsif j == 4
      shift.thursday_time_id = id
    elsif j == 5
      shift.friday_time_id = id
    elsif j == 6
      shift.saturday_time_id = id
    elsif j == 7
      shift.sunday_time_id = id
    end
  end

  private

  def validate_all_relationships
    unless self.employee_shifts.empty?
      self.errors.add_to_base "Tidak dapat di hapus karena masih memiliki data jadwal"
      false
    end
  end

end


