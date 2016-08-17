class AddTotalPremiumOnHonors < ActiveRecord::Migration
  def self.up
  	add_column :honors, :total_premium, :decimal, :precision => 12, :scale => 2
  end

  def self.down
  	remove_column :honors, :total_premium
  end
end
