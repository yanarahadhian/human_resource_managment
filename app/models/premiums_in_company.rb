# == Schema Information
#
# Table name: premiums_in_companies
#
#  id                       :integer(4)      not null, primary key
#  company_id               :integer(4)
#  premium_id               :integer(4)
#  calculated_on_overtime   :boolean(1)
#  calculated_on_salary_cut :boolean(1)
#  created_at               :datetime
#  updated_at               :datetime
#  count_daily              :boolean(1)
#

class PremiumsInCompany < ActiveRecord::Base
  belongs_to :premium
  has_one :premium_master_data
end

