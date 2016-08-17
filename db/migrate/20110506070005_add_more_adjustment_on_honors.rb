class AddMoreAdjustmentOnHonors < ActiveRecord::Migration
  def self.up
    add_column :honors, :more_adjustment, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    remove_column :honors, :more_adjustment
  end
end
