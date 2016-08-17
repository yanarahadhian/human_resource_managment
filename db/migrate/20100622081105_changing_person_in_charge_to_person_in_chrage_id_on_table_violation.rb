class ChangingPersonInChargeToPersonInChrageIdOnTableViolation < ActiveRecord::Migration
  def self.up
    rename_column :violations, :person_in_charge, :person_in_charge_id
  end

  def self.down
    rename_column :violations, :person_in_charge_id, :person_in_charge
  end
end
