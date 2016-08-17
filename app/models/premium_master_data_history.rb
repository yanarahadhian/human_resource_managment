class PremiumMasterDataHistory < ActiveRecord::Base
  belongs_to :salary_master_data_history
  belongs_to :premium, :foreign_key=> :premiums_in_company_id
end
