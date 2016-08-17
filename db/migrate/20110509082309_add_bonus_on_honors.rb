class AddBonusOnHonors < ActiveRecord::Migration
  def self.up
    add_column :honors, :bonus, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    remove_column :honors, :bonus
  end
end