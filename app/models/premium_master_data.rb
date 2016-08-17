# == Schema Information
#
# Table name: premium_master_datas
#
#  id                     :integer(4)      not null, primary key
#  salary_master_data_id  :integer(4)
#  premiums_in_company_id :integer(10)
#  value                  :decimal(12, 2)
#  created_at             :datetime
#  updated_at             :datetime
#

class PremiumMasterData < ActiveRecord::Base
  belongs_to :salary_master_data
  belongs_to :premium, :foreign_key=> :premiums_in_company_id
end
