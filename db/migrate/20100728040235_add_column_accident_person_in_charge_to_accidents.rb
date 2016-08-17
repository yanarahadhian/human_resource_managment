class AddColumnAccidentPersonInChargeToAccidents < ActiveRecord::Migration
  def self.up
    add_column :accidents, :accident_person_in_charge, :string
  end

  def self.down
    remove_column :accidents, :accident_person_in_charge
  end
end
