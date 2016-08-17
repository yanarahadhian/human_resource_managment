class AddBreakChoiceToShifts < ActiveRecord::Migration
  def self.up
    add_column :shifts, :break_choice, :string, :length => 10
  end

  def self.down
    remove_column :shifts, :break_choice
  end
end
