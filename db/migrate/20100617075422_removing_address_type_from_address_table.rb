class RemovingAddressTypeFromAddressTable < ActiveRecord::Migration
  def self.up
    remove_column(:addresses, :address_type)
  end

  def self.down
    add_column :addresses, :address_type, :string
  end
end
