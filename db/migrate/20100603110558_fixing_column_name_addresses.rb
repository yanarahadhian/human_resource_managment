class FixingColumnNameAddresses < ActiveRecord::Migration
  def self.up
    rename_column(:addresses, :string1, :street1)
    rename_column(:addresses, :string2, :street2)
  end

  def self.down
    rename_column(:addresses, :street1, :string1)
    rename_column(:addresses, :street2, :string2)
  end
end
