# == Schema Information
#
# Table name: premium_in_honors
#
#  id            :integer(4)      not null, primary key
#  company_id    :integer(4)
#  premium_id    :integer(4)
#  honor_id      :integer(4)
#  premium_value :decimal(12, 2)
#  created_at    :datetime
#  updated_at    :datetime
#

class PremiumInHonor < ActiveRecord::Base
  belongs_to :honor
  belongs_to :premium
end


