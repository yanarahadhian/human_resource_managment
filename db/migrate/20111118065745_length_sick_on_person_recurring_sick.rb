class LengthSickOnPersonRecurringSick < ActiveRecord::Migration
  def self.up
    remove_column :person_recurring_sicks, :length_sick
  end

  def self.down
    add_column :person_recurring_sicks, :length_sick, :integer
  end
end
