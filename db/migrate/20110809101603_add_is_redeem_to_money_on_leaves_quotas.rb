class AddIsRedeemToMoneyOnLeavesQuotas < ActiveRecord::Migration
  def self.up
    add_column :leaves_quotas, :is_redeem_to_money, :boolean
  end

  def self.down
    remove_column :leaves_quotas, :is_redeem_to_money
  end
end
