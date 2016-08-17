class AddRedeemedDaysOnLeavesQuotas < ActiveRecord::Migration
  def self.up
    add_column :leaves_quotas, :redeemed_days, :integer
  end

  def self.down
    remove_column :leaves_quotas, :redeemed_days
  end
end
