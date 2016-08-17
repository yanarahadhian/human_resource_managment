# == Schema Information
#
# Table name: leaves_quotas
#
#  id                 :integer(4)      not null, primary key
#  company_id         :integer(4)
#  quota              :integer(4)
#  start_date         :date
#  end_date           :date
#  redeem_date        :date
#  created_at         :datetime
#  updated_at         :datetime
#  person_id          :integer(4)
#  redeemed_days      :integer(4)
#  is_redeem_to_money :boolean(1)
#

class LeavesQuota < ActiveRecord::Base
  belongs_to :person

  def transfer_quota(redeem_to_money = false)
    person = self.person
    date = self.start_date - 1.day
    last_year_quota = person.leaves_quotas.my_quota(date)
    if last_year_quota
      quota = person.leaves_quotas.remaining_quota(date)
      if quota > 0
        unless redeem_to_money
          self.quota += quota
        end
        last_year_quota.is_redeem_to_money = redeem_to_money
        last_year_quota.redeem_date = Date.today
        if last_year_quota.redeemed_days
          last_year_quota.redeemed_days += quota
        else
          last_year_quota.redeemed_days = quota
        end
        self.save!
        last_year_quota.save!
      else
        return false
      end
    else
      return false
    end
  end

  def quota_val
    rv = 0
    rv = self.quota if self.quota
    rv
  end
end


