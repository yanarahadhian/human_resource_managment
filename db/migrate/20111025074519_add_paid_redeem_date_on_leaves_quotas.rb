class AddPaidRedeemDateOnLeavesQuotas < ActiveRecord::Migration
  def self.up
  	add_column :leaves_quotas, :paid_redeem_date, :date
  end

  def self.down
  	remove_column :leaves_quotas, :paid_redeem_date
  end
end