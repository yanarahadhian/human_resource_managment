class RenameColumnsOnPremiumInHonors < ActiveRecord::Migration
  def self.up
    rename_column :premium_in_honors, :premiums_id, :premium_id
    rename_column :premium_in_honors, :honors_id, :honor_id
  end

  def self.down
    rename_column :premium_in_honors, :premium_id, :premiums_id
    rename_column :premium_in_honors, :honor_id
  end
end
