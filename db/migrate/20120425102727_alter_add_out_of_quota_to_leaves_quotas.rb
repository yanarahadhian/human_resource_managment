class AlterAddOutOfQuotaToLeavesQuotas < ActiveRecord::Migration
  def self.up
    add_column :leaves_quotas, :out_of_quota, :date
  end

  def self.down
    remove_column :leaves_quotas, :out_of_quota
  end
end
