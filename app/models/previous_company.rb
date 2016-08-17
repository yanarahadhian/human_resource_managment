# == Schema Information
#
# Table name: previous_companies
#
#  id               :integer(4)      not null, primary key
#  company_name     :string(255)
#  company_industry :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  company_id       :integer(4)
#

class PreviousCompany < ActiveRecord::Base
  has_one :hr_setting
  has_many :experiences
  has_many :people
  has_many :addresses, :as => :owner
  has_many :departments
  has_many :divisions
  has_many :shifts
  has_many :work_groups
  has_many :join_leaves
  has_many :national_holidays
  has_many :employee_leaves
  has_many :leaves_quotas
  has_many :presences
  has_many :positions
  accepts_nested_attributes_for :addresses
  has_one :experience

  validates_presence_of :company_name#, :company_industry


end


