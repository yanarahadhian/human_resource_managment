class AddCountDailyOnPremiumsInCompanies < ActiveRecord::Migration
  def self.up
    add_column :premiums_in_companies, :count_daily, :boolean
  end

  def self.down
    remove_column :premiums_in_companies, :count_daily
  end
end