# == Schema Information
#
# Table name: payroll_settings
#
#  id                         :integer(4)      not null, primary key
#  company_id                 :integer(4)
#  full_working_days          :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  company_cover_jamsostek    :decimal(12, 2)
#  bca_branch_code            :string(255)
#  bca_company_code           :string(255)
#  bca_company_initial        :string(255)
#  bca_company_account_number :string(255)
#  payroll_by_bca             :boolean(1)
#  cut_off_date               :integer(4)

class PayrollSetting < ActiveRecord::Base
  # belongs_to :company_id
  has_many :premiums_in_companies, :dependent => :destroy
  attr_accessible :jamsostek_by_company, :jamsostek_paid_by_company, :full_working_days, 
  :company_cover_jamsostek, :bca_branch_code, :bca_company_code, :bca_company_initial,
   :bca_company_account_number, :payroll_by_bca, :cut_off_date,:use_logo_in_payroll_slip, :jamsostek_value

  # validates_numericality_of :company_cover_jamsostek , :message=>'persentase harus angka', :if => :jamsostek_by_company?
  validates_numericality_of :full_working_days , :message=>'hari harus angka'

  before_save :check_jamsostek
  after_save :set_payroll_setting_on_hr_setting

  def set_payroll_setting_on_hr_setting
    hr_setting = HrSetting.find_by_company_id(self.company_id)
    hr_setting.update_attributes(:payroll_setting_is_set => true) if !hr_setting.blank? && !hr_setting.payroll_setting_is_set
  end

  def check_jamsostek
    self.jamsostek_paid_by_company = false if !jamsostek_by_company
    self.company_cover_jamsostek = 0 if !jamsostek_paid_by_company || !jamsostek_by_company
  end 

  # Untuk sekarang fokus untuk CGNP saja
  def assumed_full_working_days
    return full_working_days.to_i
  end

  def self.revalidate_jamsostek(param)
    
  end


end