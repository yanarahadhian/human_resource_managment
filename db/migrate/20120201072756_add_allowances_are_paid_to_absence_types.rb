class AddAllowancesArePaidToAbsenceTypes < ActiveRecord::Migration
  def self.up
    add_column :absence_types, :allowance_are_paid, :boolean
  end

  def self.down
    remove_column :absence_types, :allowance_are_paid
  end
end
