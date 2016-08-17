class AddClaimAndBiayaToAccident < ActiveRecord::Migration
  def self.up
    add_column :accidents, :claim, :string
    add_column :accidents, :biaya, :decimal
  end

  def self.down
    remove_column :accidents, :claim
    remove_column :accidents, :biaya
  end
end
