class AddLessAdjustmentOnHonors < ActiveRecord::Migration
  def self.up
    add_column :honors, :less_adjustment, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    remove_column :honors, :less_adjustment
  end
end