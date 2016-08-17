# == Schema Information
#
# Table name: awards
#
#  id           :integer(4)      not null, primary key
#  award_name   :string(255)
#  award_date   :date
#  period_type  :string(255)
#  period_id    :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#  person_id    :string(255)
#  awards_giver :string(255)
#  company_id   :integer(4)
#

class Award < ActiveRecord::Base
  
  belongs_to :person

  def self.param_date_to_str(award)
    award.update(:award_date => award[:award_date].to_date) unless award[:award_date].blank?
    return award
  end
end

