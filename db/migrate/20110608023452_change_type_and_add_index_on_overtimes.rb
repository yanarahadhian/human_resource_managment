class ChangeTypeAndAddIndexOnOvertimes < ActiveRecord::Migration
  def self.up
    change_column :work_times, :length_in_hours, :decimal, :precision => 8, :scale => 4
    add_index :employee_shifts, :person_id
    add_index :employee_shifts, :shift_id
    add_index :employee_shifts, :shift_from
    add_index :employee_shifts, :shift_to
  end

  def self.down
    change_column :work_times, :length_in_hours, :integer
    remove_index :employee_shifts, :person_id
    remove_index :employee_shifts, :shift_id
    remove_index :employee_shifts, :shift_from
    remove_index :employee_shifts, :shift_to
  end
end

