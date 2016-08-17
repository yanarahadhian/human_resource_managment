class CreatePremium < ActiveRecord::Migration
  def self.up
    create_table :premium do |t|
      t.reference :company
      t.string :premium_name
      t.decimal :calculated_automatically, :precision => 12, :scale => 2
      t.timestamps
    end
  end

  def self.down
    drop_table :premium
  end
end
