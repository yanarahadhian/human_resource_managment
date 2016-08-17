class AddCountDailyOnPremiums < ActiveRecord::Migration
  def self.up
  	add_column :premiums, :count_daily, :boolean, :default => false
  end

  def self.down
  	remove_column :premiums, :count_daily
  end
end