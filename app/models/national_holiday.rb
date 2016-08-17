# == Schema Information
#
# Table name: national_holidays
#
#  id               :integer(4)      not null, primary key
#  company_id       :integer(4)
#  holiday_date     :date
#  holiday_name     :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  holiday_duration :integer(4)
#  leave_duration   :integer(4)
#

class NationalHoliday < ActiveRecord::Base

  validates_presence_of :holiday_name, :message => "Nama hari libur tidak boleh kosong"
  validates_presence_of :holiday_start_date, :message => "Tanggal mulai libur tidak boleh kosong"
  validates_presence_of :holiday_end_date, :message => "Tanggal selesai libur tidak boleh kosong"
  validate :validate_holiday_date, :message => "Tanggal ini sudah dipakai hari libur lain"
  validates_presence_of :holiday_duration, :message => "Durasi liburan tidak boleh kosong"
  validates_numericality_of :holiday_duration, :message => "Durasi liburan Harus Angka"
  validates_numericality_of :leave_duration, :message => "Lama Cuti Harus Angka", :allow_blank => true
  named_scope :by_company, lambda {|val| {:conditions => "company_id = #{val}"}}
  validate :valid_year?

  attr_protected :company_id

  def self.initializer(company_id)
    holiday = self.find(:all, :conditions => { :company_id => company_id })
    if holiday.blank?
      create_initial_data(company_id)
    end
  end

  def self.create_initial_data(company_id)
     data =[]
     data << {:holiday_name => "Tahun Baru Imlek", :holiday_duration => 1, :leave_duration=> 0, :holiday_start_date => "2012-01-23", :holiday_end_date=> "2012-01-23"}
     data << {:holiday_name => "Hari Raya Nyepi Tahun Baru Saka", :holiday_duration => 1, :leave_duration=> 0, :holiday_start_date => "2012-03-23", :holiday_end_date=> "2012-03-23"}
     data << {:holiday_name => "Wafat Yesus Kristus", :holiday_duration => 1, :leave_duration=> 0, :holiday_start_date => "2012-04-06", :holiday_end_date=> "2012-04-06"}
     data << {:holiday_name => "Kenaikan Yesus Kristus", :holiday_duration => 1, :leave_duration=> 0, :holiday_start_date => "2012-05-17", :holiday_end_date=> "2012-05-17"}
     data << {:holiday_name => "Hari Kemerdekaan RI", :holiday_duration => 1, :leave_duration=> 0, :holiday_start_date => "2012-08-17", :holiday_end_date=> "2012-08-17"}
     data << {:holiday_name => "Hari Raya Idul Fitri", :holiday_duration => 5, :leave_duration=> 3, :holiday_start_date => "2012-08-20", :holiday_end_date=> "2012-08-25"}
     data << {:holiday_name => "Hari Raya Idul Adha", :holiday_duration => 1, :leave_duration=> 0, :holiday_start_date => "2012-10-26", :holiday_end_date=> "2012-10-26"}
     data << {:holiday_name => "Tahun Baru Hijriyah", :holiday_duration => 1, :leave_duration=> 0, :holiday_start_date => "2012-11-15", :holiday_end_date=> "2012-11-15"}
     data << {:holiday_name => "Hari Natal", :holiday_duration => 1, :leave_duration=> 0, :holiday_start_date => "2012-12-25", :holiday_end_date=> "2012-12-25"}
     data << {:holiday_name => "Hari Natal Lanjutan", :holiday_duration => 3, :leave_duration=> 3, :holiday_start_date => "2012-12-26", :holiday_end_date=> "2012-12-28"}
     data << {:holiday_name => "Tahun Baru 2013", :holiday_duration => 2, :leave_duration=> 1, :holiday_start_date => "2012-12-31", :holiday_end_date=> "2013-01-01"}
     NationalHoliday.create(data).each do |x|
       x.update_attribute(:company_id, company_id)
     end
  end

  def valid_year?
    if (holiday_end_date < holiday_start_date)
      errors.add(:holiday_end_date, "Tanggal akhir libur tidak bulah lebih awal dari tanggal awal libur")
    end if !holiday_end_date.blank? && !holiday_start_date.blank?
  end

  def self.save_holiday(params,company_id)
    holiday = NationalHoliday.new(params['holiday'])
    holiday.company_id = company_id
    holiday.save
  end

  def self.join_leaves_count(company_id, start_date, end_date)
    holidays = NationalHoliday.all(:conditions => ['company_id = ? AND (holiday_start_date BETWEEN ? AND ? OR holiday_end_date BETWEEN ? AND ?)', company_id, start_date, end_date, start_date, end_date])
    rv = 0
    rv = holidays.sum{|x| x.leave_duration.to_i}
    rv
  end

  def self.holiday_dates(company_id, start_date, end_date)
    holidays = NationalHoliday.all(:conditions => ['company_id = ? AND (holiday_start_date BETWEEN ? AND ? OR holiday_end_date BETWEEN ? AND ? OR ? BETWEEN holiday_start_date AND holiday_end_date OR ? BETWEEN holiday_start_date AND holiday_end_date)', company_id, start_date, end_date, start_date, end_date, start_date, end_date ])
    dates = []
    holidays.each do |holiday|
      dates << (holiday.holiday_start_date .. holiday.holiday_end_date).to_a
    end unless holidays.blank?
    return dates.uniq
  end

  def self.is_holiday?(company_id, date)
    holiday = NationalHoliday.all(:conditions => ['company_id = ? AND ? BETWEEN holiday_start_date AND holiday_end_date', company_id, date ])
    unless holiday.blank?
      return true
    else
      return false
    end
  end

  def self.search_filter(f, company_id)
    cond = get_str_kondisi(f, company_id)
    holiday = NationalHoliday.all(:conditions => cond, :order => "holiday_start_date")
    return holiday
  end

  def self.get_str_kondisi(f, company_id)
    array_cond = []
    cond = "company_id = ?"
    array_cond << cond
    array_cond << company_id
    unless f.blank?
      unless f[:nama].blank?
        cond << " AND holiday_name like ?"
        array_cond << "%#{f[:nama]}%"
      end
      unless f[:duration].blank?
        cond << " AND holiday_duration = ?"
        array_cond << f[:duration]
      end
      unless f[:together_holiday].blank?
        cond << " AND leave_duration = ?"
        array_cond << f[:together_holiday]
      end
      unless f[:periode].blank?
        cond << " AND ? between holiday_start_date AND holiday_end_date"
        array_cond << f[:periode]
      end
    end
    return array_cond
  end

  private
  def validate_holiday_date

  end

end


