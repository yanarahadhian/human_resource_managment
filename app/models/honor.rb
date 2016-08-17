class Honor < ActiveRecord::Base
  belongs_to :person
  belongs_to :company
  has_many :premium_in_honors, :dependent => :destroy
  attr_accessor :item_kembali, :skip_before_save

  has_many :premium_in_honors, :dependent => :destroy
  accepts_nested_attributes_for :premium_in_honors, :reject_if => lambda { |a| a.values.all?(&:blank?) }, :allow_destroy => true

  validates_presence_of :salary, :message =>'Data tidak boleh kosong'
  validates_numericality_of :salary, :message =>'Data harus angka'

  before_save :calculate_salary_infos
  after_create :insert_premiums, :update_last_year_quota

  def update_last_year_quota
    unless self.leaves_redemption.blank?
      this_year_quota = self.person.leave_quota
      last_year_quota = self.person.leaves_quotas.my_quota(this_year_quota.start_date.to_date - 1)
      if last_year_quota && last_year_quota.is_redeem_to_money && last_year_quota.paid_redeem_date.blank?
        last_year_quota.update_attributes(:paid_redeem_date => self.honor_date)
      end
    end
  end

  def self.find_and_make_sure_user_has_access(honor_id, current_company_id)
    if honor_id and current_company_id
      begin
        honor = Honor.find(honor_id)
      rescue
        honor = nil
      end
    end
    honor
  end

  def calculate_salary_infos
    unless self.skip_before_save
      if self.is_thr?
        count_bonus_or_thr
      else
        self.overtime_compensation = count_overtimes(self.person, self.start_period, self.end_period)[:total_overtime]
        self.total_premium = self.count_premiums(self.person, self.start_period, self.end_period)
        self.jamsostek_cut = self.count_jamsostek_cut(self.person)
        self.jamsostek_house_cut = self.count_jamsostek_house_cut
        self.jamsostek_insurance = self.count_jamsostek_insurance
        list_unpaid = self.person.absences.list_total_unpaid(self.person.company_id, self.start_period, self.end_period)
        list_unpaid = list_unpaid.collect{ |x| x unless x.is_cut_employee_leave_quota }.compact! unless  list_unpaid.blank?
        #self.salary_cut, premiums = self.count_salary_cut(self.person, self.start_period, self.end_period, list_unpaid)

        self.gross_income = self.count_gross_income
        self.position_expenses = self.count_position_expenses

        self.month_net_income = self.count_month_net_income

        # Pembulatan
        # self.rounding_off = rounded(self.final_take_home_pay)[:rounding_of]
        self.rounding_off_month_net_income = 0 #count_rounding_off(self.month_net_income)[:rounding_of_month_net_income]

        self.year_net_income = self.count_year_net_income
        self.ptkp = self.count_ptkp
        self.pkp = self.count_pkp

        self.pph_indebted_per_year = self.count_pph_indebted_per_year
        self.pph_indebted_per_month = self.count_pph_indebted_per_month
        self.final_take_home_pay = self.count_take_home_pay
        self.rounding_off = rounded(self.final_take_home_pay)[:rounding_of]

        # Upah bersih
        self.total_final_take_home_pay = rounded(self.final_take_home_pay)[:rounded]
        self.honor_date = Time.now
      end
    end
  end

  def pph_with_thr
    tax_salary_plus_thr = 0.0
    person = Person.find(self.person_id)
    penalty = person.no_npwp.blank? ? 0.2 : 0.0
    tax_salary_plus_thr = Honor.count_tax_layers(self.pkp, person)
    tax_salary_plus_thr
  end

  def last_non_thr_honor
    Honor.find(:last, :conditions => [" is_thr = 0  and person_id = ?", self.person_id])
  end

  # Method untuk menghitung pajak lapisan 2 - 5
  def self.count_tax_layers(employee_pkp, person)
    penalty = person.no_npwp.blank? ? 0.2 : 0.0
    tax = 0.0
    if employee_pkp >= 200000000
      tax = count_tax_layer(employee_pkp - 200000000, penalty, 0.35)
      tax += count_tax_layer(100000000, penalty, 0.25)
      tax += count_tax_layer(50000000, penalty, 0.15)
      tax += count_tax_layer(50000000, penalty, 0.05)
    elsif employee_pkp < 200000000 and employee_pkp > 100000000
      tax = count_tax_layer(employee_pkp - 100000000, penalty, 0.25)
      tax += count_tax_layer(50000000, penalty, 0.15)
      tax += count_tax_layer(50000000, penalty, 0.05)
    elsif employee_pkp < 100000000 and employee_pkp > 50000000
      tax = count_tax_layer(employee_pkp - 50000000, penalty, 0.15)
      tax += count_tax_layer(50000000, penalty, 0.05)
    else
      tax += count_tax_layer(employee_pkp, penalty, 0.05)
    end
    tax
  end

  def self.count_tax_layer(employee_pkp, penalty, tax_percentage)
    ((penalty * tax_percentage) * employee_pkp) + (tax_percentage * employee_pkp)
  end

  def count_bonus_or_thr
    user_last_honor = self.last_non_thr_honor

    if user_last_honor
      thr_value = self.salary
      current_honor_month = self.honor_month
      current_honor_year = self.honor_year
      current_file_name = self.file_name
      self.attributes = user_last_honor.attributes

      self.salary = thr_value
      self.honor_month = current_honor_month
      self.file_name = current_file_name
      self.honor_year = current_honor_year

      months_work = self.count_month

      yearly_gross_income = (self.gross_income * months_work) + thr_value

      yearly_position_expenses = 0.05 * yearly_gross_income
      yearly_position_expenses = yearly_position_expenses > 6000000 ? 6000000 : yearly_position_expenses
      self.position_expenses = yearly_position_expenses / months_work

      self.year_net_income = yearly_gross_income - yearly_position_expenses
      self.month_net_income = self.year_net_income / months_work
      self.pkp = self.year_net_income - self.ptkp

      if self.pkp > 0

        last_month_tax = self.pph_indebted_per_year

        tax_salary_plus_thr = self.pph_with_thr

        self.pph_indebted_per_year = tax_salary_plus_thr - last_month_tax
        self.pph_indebted_per_month = self.pph_indebted_per_year
        self.total_final_take_home_pay = self.salary - self.pph_indebted_per_month

      else
        self.pph_indebted_per_month = 0
        self.pph_indebted_per_year = 0
        self.total_final_take_home_pay = self.salary
      end

      self.rounding_off = rounded(self.final_take_home_pay)[:rounding_of]
    else
      self.total_final_take_home_pay = self.salary
      self.pph_indebted_per_month = 0.0
    end
    self.is_thr = true
    self.start_period = nil
    self.end_period = nil
    self.honor_date = Time.now
    self.salary_cut = nil
    self.total_premium = nil
    self.final_take_home_pay =  self.total_final_take_home_pay
  end

  def rounded(money)
    hundred = money.to_s.split(".").first
    last_hundred = hundred.size
    value = hundred[last_hundred-2 ,last_hundred-1]

    x = 100 - value.to_i
    if x >= 50
      rounding_off = -(100-x)
    else
      rounding_off = x
    end
    return {:rounding_of => rounding_off, :rounded => (rounding_off + hundred.to_i)}
  end

  def count_rounding_off(month_net_income)
    hundred = month_net_income.to_s.split(".").first
    last_hundred = hundred.size
    value = hundred[last_hundred-2 ,last_hundred-1]

    x = 100 - value.to_i
    if x >= 50
      rounding_off = -(100-x)
    else
      rounding_off = x
    end
    return {:rounding_of => rounding_off, :rounding_of_month_net_income => (rounding_off + hundred.to_i)}
  end

  def count_total_final_take_home_pay
    return self.rounding_off_month_net_income
  end

  def count_salary(person, start_date, end_date)
    tot_basic_salary = 0
    if end_date != '--' || start_date != '--'
      if start_date.to_date < end_date.to_date
        salary_master_data = person.salary_master_data
        unless salary_master_data.blank?
          histories_master = salary_master_data.salary_master_data_histories
          unless histories_master.blank?
            histories = histories_master.find_by_periode(start_date, end_date)
            histories.each do |x|
              tot_basic_salary += x.basic_salary.to_f
            end
            tot_basic_salary = tot_basic_salary/histories.count
          end
	end
      end
    end
    return tot_basic_salary
  end

  # Gaji pokok per hari
  def day_basic_salary
    return self.salary/30
  end

  # Hitung total bersih gaji yg dibawa pulang
  # more_adjustment = kelebihan bayar
  # less_adjustment = kekurangan bayar
  def count_take_home_pay
    v = self.gross_income - self.pph_indebted_per_month.to_f + self.more_adjustment.to_f - self.less_adjustment.to_f - self.debt.to_f
    v = v - (self.jamsostek_cut + self.count_jamsostek_house_cut.to_f + self.count_jamsostek_insurance.to_f + self.cooperation_cut.to_f) if !self.is_thr?
    return v
  end

  # Potongan absensi harian
  def count_salary_cut(person, start_date, end_date, absences=[])
    salary_cut = 0
    premium_cut = 0
    total_salary_cut = 0
    premiums_list = []

    absences = person.absences.list_total_unpaid(person.company_id, start_date, end_date) if absences.blank?
    # Note: Hitung berapa jumlah hari yang tidak hadir dan tidak di cover oleh pemotongan cuti, sehingga harus potong gaji
    total_days_unpaid = Absence.count_days_are_not_covered_by_leaves_quota(absences)

    if !total_days_unpaid.blank? && total_days_unpaid > 0
      salary_in_a_day = self.salary/assumed_working_days(person)
      salary_cut = salary_in_a_day*total_days_unpaid
    end
    premium_cut, premiums_list = count_total_premium_cut(person,total_days_unpaid )
    total_salary_cut = salary_cut + premium_cut
    return total_salary_cut.to_i, premiums_list
  end

  def count_total_premium_cut(person, total_unpaid=0)

    premium_cut_value = 0
    data_master = SalaryMasterData.find_by_person_id(person.id)
    unless data_master.blank?
      premiums_in_company = PremiumMasterData.find(:all,
        :conditions => { :salary_master_data_id => data_master.id}, :include => :premium)
      company_working_days = person.company_payroll_setting.full_working_days

      premiums_in_company.each do |pic|
        unless pic.premium.blank?
          if pic.premium.calculated_on_salary_cut
            if pic.premium.count_daily
              premium_cut_value += total_unpaid * pic.value
            else
              premium_cut_value += (total_unpaid/company_working_days.to_f) * pic.value.to_f
            end
          end
        end
      end
    end
    return premium_cut_value, premiums_in_company
  end

  # Bila dia ga masuk berturut2 (sakit keras), kan dianggap dibayar
  # Namun, bila lebih dari 3 bulan, dipotong 25%; lebih dari 6 bulan dipotong 50%, dst.
  # Bila dia ga masuk berturut2 (sakit keras), kan dianggap dibayar
  # Namun, bila lebih dari 3 bulan, dipotong 25%; lebih dari 6 bulan dipotong 50%, dst.
  def set_salary_with_sequential_salary_cut(person, start_date)
    salary_cut = 0
    desc = ""
    current_salary = person.get_current_salary(self)
    working_days = assumed_working_days(person)
    bulan = get_total_days_absence(person, start_date)
    salary_cut = 0
    if working_days > 0 && bulan > 0
      # salary_cut = (assumed_working_days.to_i - person.absences.total_unpaid(self.honor_month, self.honor_year).to_i) / assumed_working_days(person) * self.salary
      #salary_cut = (working_days.to_i - person.absences.total_unpaid(person.company_id,honor_month, honor_year).to_i) / working_days * person.honors.last.salary.to_f
      if bulan == 3
        salary_cut = 0.25 * current_salary
        desc = "Gaji pokok dipotong sebesar 25%"
      elsif bulan == 6
        salary_cut = 0.5 * current_salary
        desc = "Gaji pokok dipotong sebesar 50%"
      elsif bulan == 9
        salary_cut = 0.75 * current_salary
        desc = "Gaji pokok dipotong sebesar 75%"
      elsif bulan == 12
        salary_cut = current_salary
        desc = "Gaji pokok dipotong sebesar 100%"
      end
    end
    self.salary = current_salary - salary_cut
    return {:desc => desc, :tot_sakit => bulan }
  end

  def get_total_days_absence(person, start_date)
    bulan = 0;
    [3,6,9,12].each do |x|
      recurring = person.person_recurring_sicks.total_sickniesses_by_month(x, start_date)
      unless recurring.blank?
        bulan = x
      else
        break;
      end
    end
    return bulan
  end

  # Total of all components
  def count_gross_income
    self.salary.to_f + self.overtime_compensation.to_f + self.total_premium.to_f + self.leaves_redemption.to_f + self.bonus.to_f - self.salary_cut.to_f
  end

  # Biaya jabatan
  def count_position_expenses
    expenses = 0
    if !self.person.current_work_contract.blank? && !self.person.current_work_contract.is_daily_employee
      expenses = [0.05 * self.gross_income, 500000].min
    end
    return expenses
  end

  # Get net income per month
  def count_month_net_income
    if !self.person.current_work_contract.blank? && !self.person.current_work_contract.is_daily_employee
      if self.is_thr? && !last_honor.blank?
        new_gross_income - new_position_expenses
      else
        self.gross_income - self.position_expenses
      end
    else
      return self.gross_income
    end
  end

  # Cari pendapatan bruto dan biaya jabatan bulan sebelumnya
  def last_honor
    conditions = 'person_id = ? AND company_id = ? AND  is_thr =?', self.person_id, self.company_id, false
    last_honor = Honor.find(:last,:select => 'id, salary, honor_date, pph_indebted_per_month, pph_indebted_per_year', :conditions => conditions)
  end

  def last_gross_income
    last_honor.salary*count_month unless last_honor.blank?
  end

  def new_gross_income
    self.gross_income + last_gross_income unless last_gross_income.blank?
  end

  def last_position_expenses
    last_position_expenses = 0.05*last_gross_income unless last_gross_income.blank?
  end

  def new_position_expenses
    self.position_expenses + last_position_expenses unless last_position_expenses.blank?
  end

  # Hitung pedapatan dalam satu tahun
  def count_year_net_income
    if self.is_thr?
      self.month_net_income
    else
      (count_month * self.month_net_income.to_i)
    end
  end

  def count_month
    month = 0
    emp = self.person.current_employment
    unless emp.blank?
      started_work = emp.employment_start
      if self.end_period.nil?
        month = 12
      elsif started_work.year < self.end_period.year
        month = 12
      else
        month = 12 - started_work.month + 1
      end
    end
    return month
  end

  # Get a month-year
  def month_year
    self.honor_date.strftime('%B %Y')
  end

  # Get a year
  def get_year
    self.honor_date.year
  end

  # Get a month
  def get_month
    self.honor_date.month
  end

  # Hitung PTKP (Penghasilan Tidak Kena Pajak)
  def count_ptkp
    ptkp = self.person.tax_status.blank? ? 0 : 12 * self.person.tax_status.ptkp
    return ptkp
  end

  # Hitung PKP (Penghasilan Kena Pajak)
  def count_pkp
    if !self.person.current_work_contract.blank? && self.person.current_work_contract.is_daily_employee
      v = (((self.gross_income - self.ptkp)/1000).to_i)*1000
    else
      if self.ptkp > self.year_net_income
        v = 0
      else
        v = (((self.year_net_income - self.ptkp)/1000).to_i)*1000
      end
    end
    return v
  end

  # Pajak tahun ini
  # Tarif PPh Pasal 17 UU PPh No 36 tahun 2008
  # s.d. Rp. 50.000.000,00  5 %
  # Di atas Rp. 50.000.000,00 s.d Rp. 250.000.000,00  15%
  # Di atas Rp. 250.000.000,00 s.d. Rp. 500.000.000,00  25 %Di atas Rp. 500.000.000,00  30 %
  # Di atas Rp. 500.000.000,00  30 %
  def count_pph_indebted_per_year
    current_pkp = self.pkp

    limit1 = 50000000
    if current_pkp > 250000000
      limit2 = 200000000
    else
      limit2 = current_pkp-limit1
    end

    if current_pkp > (limit1+limit2)
      limit3 = 250000000
    else
      limit3 = current_pkp-(limit1+limit2)
    end

    if current_pkp <= (limit1+limit2+limit3)
      limit4 = 500000000
    else
      limit4 = current_pkp-(limit1+limit2+limit3)
    end

    self.person.no_npwp.blank? ? penalty = 0.2 : penalty = 0.0
    rate_under_50_million                    = (1.0+penalty)*0.05
    rate_above_50_million_under_250_million  = (1.0+penalty)*0.15
    rate_above_250_million_under_500_million = (1.0+penalty)*0.25
    rate_above_500_milion                    = (1.0+penalty)*0.30

    value_under_50_million = rate_under_50_million*[limit1, current_pkp].min
    value_above_50_million_under_250_million = rate_above_50_million_under_250_million*limit2 if current_pkp > limit1
    value_above_250_million_under_500_million = rate_above_250_million_under_500_million*limit3 if current_pkp > limit2
    value_above_500_million = rate_above_500_milion*limit4 if current_pkp >= limit4

    self.pph_indebted_per_year = (value_under_50_million.to_f + value_above_50_million_under_250_million.to_f + value_above_250_million_under_500_million.to_f + value_above_500_million.to_f)
    return self.pph_indebted_per_year
  end

  def count_for_december?
    self.end_period && self.end_period.month == 12
  end

  def count_paid_tax
    paid_taxes = 0
    total_net_income = 0
    honors_paid_this_year = self.person.honors.find(:all, :conditions => ["YEAR(end_period) = ?", self.end_period.year] )
    unless honors_paid_this_year.blank?
      honors_paid_this_year.each do |honor_paid|
        if honor_paid.id != self.id
          paid_taxes += honor_paid.pph_indebted_per_month
          total_net_income += honor_paid.month_net_income
        end
      end
    end
    return total_net_income, paid_taxes
  end

  # Pajak bulan ini
  def count_pph_indebted_per_month
    months_works = count_month
    rv = 0
    if pph_indebted_per_year > 0
      if self.is_thr? && !last_honor.blank?
        rv = self.pph_indebted_per_year - last_honor.pph_indebted_per_year
      else
        if self.count_for_december?
          #NOTES: Di bulan desember hitung pajak adalah perhitungan total pajak 1 tahun - pajak yang sudah
          #dibayar di tahun tersebut
          paid_tax = 0
          total_net_income = 0


          total_net_income, paid_tax = count_paid_tax
          total_net_income += self.month_net_income
          self.year_net_income = total_net_income
          if total_net_income > self.ptkp
            self.pkp = total_net_income - self.ptkp
            self.pph_indebted_per_year = count_pph_indebted_per_year
            rv = (self.pph_indebted_per_year - paid_tax )# / months_works
            # Dianggap 0 kalau ada kelebihan bayar
            rv = 0 if rv < 0
          else
            self.pkp = 0
            self.pph_indebted_per_year = 0
            rv = 0
          end
        else
          rv = (self.pph_indebted_per_year / months_works).round
        end

      end
    end
    rv
  end

  # Count all overtimes that belong to a person
  # summary_overtime(start_date, end_date)
  def count_overtimes(person, start_date, end_date)
    total_overtime = 0
    total_overtime_hours = 0.0
    total_overtime_modifiers = 0
    overtimes = Overtime.find(:all, :conditions => ['person_id = ? AND overtime_status = ? AND overtime_date BETWEEN ? AND ?',
        person.id, "Approved", start_date , end_date ])

    if !overtimes.blank?
      if person.company_hr_setting.is_company_overtime
        overtimes.each do |overtime|
          total_overtime_hours += overtime.overtime_length_in_minutes if overtime.overtime_length_in_minutes
        end
        total_overtime_hours = (total_overtime_hours.to_f / 60) if total_overtime_hours > 0
      else
        #        overtime_summary = person.overtimes.summary_overtime(start_date.to_date, end_date.to_date)
        #        total_overtime_hours = overtime_summary[:overtime1] + overtime_summary[:overtime2] + overtime_summary[:overtime3] + overtime_summary[:overtime4]
        #        total_overtime_modifiers = overtime_summary[:total].to_f unless person.company_hr_setting.is_company_overtime
        total_overtime_hours, total_overtime_modifiers = count_overtime_hours_and_modifiers(person, overtimes, start_date, end_date)
      end
    end

    unless person.company_hr_setting.is_company_overtime
      unless total_overtime_modifiers.blank?
        total_overtime = total_overtime_modifiers * overtime_hourly_rate(person, start_date.to_date, end_date.to_date, total_overtime_hours)
      else
        total_overtime = total_overtime_hours * overtime_hourly_rate(person, start_date.to_date, end_date.to_date, total_overtime_hours)
      end
    else
      total_overtime = overtime_hourly_rate(person, start_date.to_date, end_date.to_date, total_overtime_hours)
    end

    return {:total_overtime_hours => total_overtime_hours,
      :total_overtime_modifiers => total_overtime_modifiers,
      :total_overtime => total_overtime,
      :overtimes => overtimes
    }
  end

  def count_overtime_hours_and_modifiers(person, overtimes, start_date, end_date)
    holidays = NationalHoliday.holiday_dates(person.company_id, start_date, end_date)
    overtime1 = 0.0
    overtime2 = 0.0
    overtime3 = 0.0
    overtime4 = 0.0
    holiday_hour = 0.0
    overtime_in_hours = 0.0
    gov_day_off = 0
    overtimes.each do |overtime|
      schedule = person.current_schedule(overtime.overtime_date)
      overtime_in_hours = overtime.overtime_length_in_minutes / 60.0
      if schedule && !holidays.flatten.include?(overtime.overtime_date)
        if overtime_in_hours > 1
          overtime1 += 1
          overtime2 += overtime_in_hours - 1
        else
          overtime1 += overtime_in_hours
        end
      else
        #Peraturan Menteri no.102/MEN/VI/2004 untuk lembur hari libur bagi yang kerja 5 hari seminggu
        if overtime_in_hours <= 8
          overtime4 += overtime_in_hours * 2
        elsif overtime_in_hours > 8
          overtime4 += 8 * 2
          num = overtime_in_hours - 8
          num.to_i.times.each do |i|
            overtime4 += 1 * (3 + i)
          end
        end
        gov_day_off = 1
      end
    end
    total_overtime_hours = (overtime1 * 1.5) + (overtime2 * 2) + overtime3 + overtime4
    total_overtime_modifiers = total_overtime_hours
    return total_overtime_hours, total_overtime_modifiers
  end

  # Count overtime hourly rate
  def overtime_hourly_rate(person, start_date, end_date, total_overtime)
    premium_value = 0
    conditions = 'company_id = ? AND  calculated_on_overtime =?', person.company_id, true
    premiums = Premium.find(:all, :conditions => conditions)
    unless person.salary_master_data.blank?
      salary = self.salary.blank? ? person.get_current_salary(self) : self.salary
      premiums.each do |premium|
        master = premium.premium_master_datas.find_by_salary_master_data_id(person.salary_master_data.id)
        if !master.blank? && master.value
          value = master.value
        else
          value = 0
        end
        premium_value += value
      end

      unless person.company_hr_setting.is_company_overtime
        # Sesuai dengan peraturan Kementrian tenaga kerja
        hourly_rate = (salary + premium_value) / 173
      else
        # Sesuai dengan upah lembur perusahaan (perhitungan lembur pro rata per jam)
        # (Total Jam Lembur/(8*jumlah hari kerja yg ditentukan perusahaan))*(Gaji Pokok + Total Tunjangan yg disertakan)
        hourly_rate = 0
        unless person.company_payroll_setting.full_working_days.blank?
          hourly_rate = (total_overtime/(8*person.company_payroll_setting.full_working_days))*(salary + premium_value)
        end
      end
    else
      return premium_value
    end
    return hourly_rate.round
  end

  def count_premiums(person, start_period, end_period)
    @pihs = []
    premium_value = 0
    data_master = SalaryMasterData.find_by_person_id(person.id)
    value = 0
    unless data_master.blank?
      premiums_in_company = data_master.premium_master_datas
      premiums_in_company.each do |pic|
        unless pic.premium.blank?
          unless person.presences.blank?
            days = person.presences.cut_off_total_work_days(start_period, end_period)[:days]
          else
            days = 0
          end
          total_work_days = pic.premium.count_daily? ? days : 1
          value = pic.value*total_work_days if pic and pic.value and total_work_days
          premium_value += (value-attendance_premium_cut(person, pic.premium,value, start_period, end_period))
          pih = PremiumInHonor.new({:company_id => pic.premium.company_id, :premium_id => pic.premium.id, :premium_value => value})
          @pihs << pih
        end
      end
    end
    return premium_value
  end

  # Potongan tunjangan
  # Selebihnya cuma untuk CGNP(32)
  # Premi hadir dipotong sebanyak 1/3 bagian jika 1 hari tidak masuk(ijin & sakit) atau cuti berturut-turut selama 3 hari
  # Dipotong 2/3 bagian jika 2 hari tidak masuk (ijin & sakit) atau cuti berturut-turut selama 4 hari
  # Tidak mendapatkan premi hadir jika tidak masuk (ijin & sakit) 3 hari atau lebih atau cuti berturut-turut selama 5 hari atau lebih.
  def attendance_premium_cut(person, premium, premium_value, start_period, end_period)
    premium_cut = 0
    if !premium.premium_name.blank? && premium.premium_name.downcase == 'premi hadir' && person.company_id == 32
      total_excuse = person.absences.total_by_type(1, start_period, end_period, person.company_id)
      if !total_excuse.blank? && total_excuse == 1
        premium_cut += premium_value/3
      elsif !total_excuse.blank? && total_excuse == 2
        premium_cut += (premium_value*2)/3
      elsif !total_excuse.blank? && total_excuse >= 3
        premium_cut += premium_value
      else
        premium_cut += 0
      end

      total_sick_leave = person.absences.total_by_type(3, start_period, end_period, person.company_id)
      if !total_sick_leave.blank? && total_sick_leave == 1
        premium_cut += premium_value/3
      elsif !total_sick_leave.blank? && total_sick_leave == 2
        premium_cut += (premium_value*2)/3
      elsif !total_sick_leave.blank? && total_sick_leave >= 3
        premium_cut += premium_value
      else
        premium_cut += 0
      end

      total_leaves = person.absences.sequential_absences(person.company_id, 2, start_period.to_date, end_period.to_date)
      total_leaves.each do |l|
        @total_leave = l[:total_days]
      end
      if !@total_leave.blank? && @total_leave == 3
        premium_cut += premium_value/3
      elsif !@total_leave.blank? && @total_leave == 4
        premium_cut += (premium_value*2)/3
      elsif !@total_leave.blank? && @total_leave >= 5
        premium_cut += premium_value
      else
        premium_cut += 0
      end
    end
    return premium_cut
  end

  def insert_premiums
    if !self.is_thr?
      @pihs.each do |pih|
        pih.update_attribute(:honor_id, self.id)
        pih.save
      end
    end
  end

  # Penguangan cuti
  def count_leaves_redemption(person, month, year)
    ps = person.company_payroll_setting
    unless ps.cut_off_date.blank?
      start_date = Date.new(year.to_i,(month.to_i)-1,ps.cut_off_date.to_i)
      end_date = Date.new(year.to_i,month.to_i,ps.cut_off_date.to_i-1)
    else
      start_date = Date.new(year.to_i,month.to_i)
      end_date = start_date.at_end_of_month
    end
    leaves_redemption = 0
    last_year_quota = person.leaves_quotas.my_quota(end_date - 1.year)

    unless last_year_quota.blank?
      unless last_year_quota.redeem_date.blank? && last_year_quota.is_redeem_to_money.blank?
        if last_year_quota.redeem_date >= start_date && last_year_quota.redeem_date <= end_date && last_year_quota.is_redeem_to_money
          leaves_remaining = last_year_quota.redeemed_days
          leaves_redemption = leaves_remaining / assumed_working_days(person)*self.salary
        end
      end
    end
    return leaves_redemption
  end

  # Total hari kerja di company
  def assumed_working_days(person)
    ps = person.company_payroll_setting
    days = 1
    unless ps.blank?
      if ps.full_working_days.to_i == 0
        days = Time.days_in_month(Time.now.month, Time.now.year)
      else
        days = ps.full_working_days.to_i
      end
    end
    return (days < 1) ? 1 : days
  end


  # Two option jamsostek value
  # UMK, must filled on view
  # Basic salary as default ot UMK = 0
  def jamsostek_value(person)
    value = 0
    ps = person.company_payroll_setting
    if !ps.blank? && !person.jamsostek_number.blank? #&& ps.jamsostek_by_company
      if ps.jamsostek_by_company
        if !ps.jamsostek_value.blank? && ps.jamsostek_value > 0
          value = ps.jamsostek_value
        else
          value = self.salary
        end
      end
    end
    return value
  end

  def count_jamsostek_cut(person)
    value = jamsostek_value(person)*0.02
  end

  # Pemotongan uang muka perumahan Jamsostek(anggota Jamsostek)
  def count_jamsostek_house_cut
    value = 0
    if !self.person.jamsostek_number.blank?
      value = self.jamsostek_house_cut
    end
    return value
  end

  # Pemotongan auransi jamsostek
  def count_jamsostek_insurance
    value = 0
    if !self.person.jamsostek_number.blank?
      value = self.jamsostek_insurance
    end
    return value
  end

  # Pemotongan koperasi untuk karyawan tetep
  def count_cooperation_cut
    value = 0
    if !self.person.current_status.contract_type.blank? && self.person.current_status.contract_type.contract_type_name == 'Tetap'
      value = self.cooperation_cut
    end
    return value
  end

  # Hitung THR berdasarkan lama dia bekerja
  def count_thr(person)
    working_days = assumed_working_days(person)
    if working_days > 3 && working_days < 12
      (working_days/12)*salary
    elsif working_days > 12
      return salary
    else
      return 0
    end
  end

  def self.search(params, options={})
    conditions = ['1=1']
    find(:all, options.merge({:conditions => conditions,:include => [:person]}))
  end

  def self.find_by_filter(f, first_kond = "")
    kondisi = ""

    unless f[:contract_type_id].blank?
      work_kontrak = WorkContract.all(:conditions => "contract_type_id=#{f[:contract_type_id]}")
      unless work_kontrak.blank?
        id_work_kontrak = work_kontrak.collect{ |x| x.id }
        kondisi << " AND " unless kondisi.blank?
        kondisi << "people.latest_work_contract_id in ('#{id_work_kontrak.join("','")}')"
      end
    end

    id_person_id = find_by_employement(f, first_kond)
    unless id_person_id.blank?
      id_person_id = id_person_id.flatten.uniq.compact
      kondisi << " AND " unless kondisi.blank?
      kondisi << "people.id in ('#{id_person_id.join("','")}')"
    end
    unless f[:name].blank?
      kondisi << " AND " unless kondisi.blank?
      kondisi << "CONCAT(people.FirstName,' ',people.LastName) like '%#{f[:name]}%'"
    end

    unless f[:nik].blank?
      kondisi << " AND " unless kondisi.blank?
      kondisi << "people.employee_identification_number like '%#{f[:nik]}%'"
    end

    return kondisi
  end

  def self.find_by_employement(f, kond = "")
    unless f[:department_id].blank?
      kond << " and "unless kond.blank?
      kond << "department_id=#{f[:department_id]}"
    end
    unless f[:division_id].blank?
      kond << " and "unless kond.blank?
      kond << "work_division_id=#{f[:division_id]}"
    end
    unless kond.blank?
      kond = "latest_employment_id in (select id from employments where #{kond})"
      person = Person.all(:conditions => kond)
      unless person.blank?
        return person.collect {|x|x.id}
      end
    else
      return nil
    end
  end

  def self.get_export_condition_by_department(current_conditions)
    sql_where = "people.latest_employment_id in (select id from employments)"
    sql_where << " AND #{current_conditions}"
    return sql_where
  end

  # judul export
  def self.title_export
    title = ["No.", "Nama Karyawan", "NPWP", "Bruto/Bulan",
      "Netto/Bulan", "Netto/Tahun", "PTKP", "PKP", "PPH/Tahun", "PPH/Bulan", "Take Home"]
    return title
  end

  # variabel summary export
  def self.variable_sum_export(premiums)
    # Row sebelum premiums
    sum = [0,0,0,0]
    unless premiums.blank?
      premiums.each do |p|
        sum << 0
      end
    end
    sum = sum + [0,0,0,0,0,0,0,0,0]
    return sum
  end

  # Export Data Gaji
  def self.data_export(honor, index, premiums, data)
    person = honor.person
    data = [index+1,
      person.full_name,
      person.no_npwp,
      honor.gross_income,
      honor.month_net_income,
      honor.year_net_income,
      honor.ptkp,
      honor.pkp,
      honor.pph_indebted_per_year,
      honor.pph_indebted_per_month,
      honor.total_final_take_home_pay
    ]
    #sum = sum_process_export(honor, sum, premiums, data)
    sum = []
    return {:data => data, :sum => sum}
  end

  def self.total_revenue(honor)
    return (honor.month_net_income.to_i - honor.pph_indebted_per_month.to_i)
  end

  # proses summare export
  def self.sum_process_export(honor, sum, premiums, data)
    i=0
    field=8
    sum[i] = sum[i] + data[field]
    sum[i+=1] = sum[i] + data[field+=1]
    sum[i+=1] = sum[i] + data[field+=1]
    data_sum = self.data_sum_premi_export(honor, sum, premiums, i, data, field+=1)
    sum = data_sum[:sum]
    i = data_sum[:i]
    field = data_sum[:field]
    sum[i+=1] = sum[i] + data[field+=1]
    sum[i+=1] = sum[i] + data[field+=1]
    sum[i+=1] = sum[i] + data[field+=1]
    sum[i+=1] = sum[i] + data[field+=1]
    sum[i+=1] = sum[i] + data[field+=1]
    sum[i+=1] = sum[i] + data[field+=1]
    sum[i+=1] = sum[i] + data[field+=1]
    sum[i+=1] = sum[i] + data[field+=1]
    sum[i+=1] = sum[i] + data[field+=1]
    return sum
  end

  def self.data_premi_export(honor, premiums)
    a =[]
    unless premiums.blank?
      # Jumlah hari kerja
      a << (honor.person.presences.blank? ? 0 : honor.person.presences.cut_off_total_work_days(honor.honor_month, honor.honor_year)[:days])
      premiums.each do |x|
        condition = "honor_id=#{honor.id} and premium_id=#{x.id}"
        prem_in_honor = PremiumInHonor.first(:conditions => condition)
        unless prem_in_honor.blank?
          a << prem_in_honor.premium_value
        else
          a << 0
        end
      end
    end
    return a
  end

  def self.data_sum_premi_export(honor, sum, premiums, i, data, field)
    unless premiums.blank?
      sum[i+=1] = sum[i] + (honor.person.presences.blank? ? 0 : data[field])
      premiums.each do |x|
        condition = "honor_id=#{honor.id} and premium_id=#{x.id}"
        prem_in_honor = PremiumInHonor.first(:conditions => condition)
        unless prem_in_honor.blank?
          sum[i+=1] = sum[i] + prem_in_honor.premium_value
        else
          sum[i+=1] = sum[i] + 0
        end
        field+=1
      end
    end
    return {:sum => sum, :i => i, :field => field}
  end

  # summary result
  def self.summary_result_export(sum)
    summary = ["","","","","","","",""]
    sum.each_with_index do |x, index|
      summary << x
    end
    return summary
  end

  def self.is_zero(sum)
    a = false
    sum.each do |x|
      a = true if x > 0
    end
    return a
  end

  def self.time_diff_in_natural_language(from_time, to_time)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_seconds = ((to_time - from_time).abs).round
    components = []

    %w(year month week day).each do |interval|
      # For each interval type, if the amount of time remaining is greater than
      # one unit, calculate how many units fit into the remaining time.
      if distance_in_seconds >= 1.send(interval)
        delta = (distance_in_seconds / 1.send(interval)).floor
        distance_in_seconds -= delta.send(interval)
        components << pluralize(delta, interval)
      end
    end

    components.join(", ")
  end

  def self.check_data(current_company_id,holding_company_id)
    check = self.find(:last,:conditions =>["company_id = ?",current_company_id])
    if check.blank?
      puts "     Running Honor"
      Person.find(:all,:conditions => ["company_id = ? and holding_company_id = ?",current_company_id,holding_company_id]).each do |d|
        new_day =0
        d.employee_shifts[0].shift_from.to_date.upto((Date.today-1.month)) do |day|
          unless new_day == day.to_time.mon
            new_day = day.to_time.mon
            basic_salary = d.salary_master_data.basic_salary
            ptkp = d.tax_status.ptkp
            data = self.new
            data.company_id = current_company_id
            data.person_id = d.id
            data.salary = basic_salary
            data.start_period = "1-#{day.mon}-#{day.year}".to_date
            data.end_period = Date.civil(day.year,day.mon,-1)
            data.save!
            require "pp"
            pp data.errors.full_messages
          end
        end
      end
    end
  end

end



# == Schema Information
#
# Table name: honors
#
#  id                            :integer(4)      not null, primary key
#  company_id                    :integer(4)
#  person_id                     :integer(4)
#  salary                        :decimal(12, 2)
#  overtime_compensation         :decimal(12, 2)
#  leaves_redemption             :decimal(12, 2)
#  jamsostek_insurance           :decimal(12, 2)
#  jamsostek_cut                 :decimal(12, 2)
#  final_take_home_pay           :decimal(12, 2)
#  salary_cut                    :decimal(12, 2)
#  debt                          :decimal(12, 2)
#  cooperation_cut               :decimal(12, 2)
#  jamsostek_house_cut           :decimal(12, 2)
#  adjustment_paid_by_company    :decimal(12, 2)
#  gross_income                  :decimal(12, 2)
#  position_expenses             :decimal(12, 2)
#  month_net_income              :decimal(12, 2)
#  year_net_income               :decimal(12, 2)
#  ptkp                          :decimal(12, 2)
#  pkp                           :decimal(12, 2)
#  pph_indebted_per_month        :decimal(12, 2)
#  pph_indebted_per_year         :decimal(12, 2)
#  honor_status                  :string(255)
#  internal_note                 :text
#  note_for_employee             :text
#  created_at                    :datetime
#  updated_at                    :datetime
#  total_premium                 :decimal(12, 2)
#  honor_month                   :integer(4)
#  honor_year                    :(4)
#  holiday_benefits              :decimal(12, 2)
#  more_adjustment               :decimal(12, 2)
#  less_adjustment               :decimal(12, 2)
#  bonus                         :decimal(12, 2)
#  honor_date                    :date
#  file_name                     :string(255)
#  is_thr                        :boolean(1)      default(FALSE)
#  rounding_off                  :decimal(12, 2)
#  rounding_off_month_net_income :decimal(12, 2)
#  total_final_take_home_pay     :decimal(12, 2)
#

