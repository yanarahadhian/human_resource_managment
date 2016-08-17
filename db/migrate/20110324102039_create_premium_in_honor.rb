class CreatePremiumInHonor < ActiveRecord::Migration
  def self.up
    create_table :premium_in_honor do |t|
      t.references :company
      t.references :premiums
      t.references :honors
      t.decimal  :premium_value, :precision => 12, :scale => 2
      t.timestamps
    end
  end

  def self.down
    drop_table :premium_in_honor
  end
end
