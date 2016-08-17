class AddPersonInCharge < ActiveRecord::Migration
  def self.up
    add_column :violations, :person_in_charge_name, :string
    remove_column :violations, :person_in_charge_id
  end

  def self.down
    remove_column :violations, :person_in_charge_name
    add_column :violations, :person_in_charge_id, :integer
  end
end
