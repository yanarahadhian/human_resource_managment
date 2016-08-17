# == Schema Information
#
# Table name: user_companies
#
#  id         :integer(4)      not null, primary key
#  company_id :integer(4)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class UserCompany < ActiveRecord::Base
  belongs_to :user
end

