class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string    :address_type
      t.string    :string1
      t.string    :string2
      t.string    :city
      t.string    :state
      t.integer   :owner_id
      t.string    :owner_type
      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
