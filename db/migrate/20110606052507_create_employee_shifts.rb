class CreateEmployeeShifts < ActiveRecord::Migration
  def self.up
    remove_column :employments, :shift_id
    create_table :employee_shifts do |t|
      t.integer :person_id
      t.integer :shift_id
      t.date :shift_from
      t.date :shift_to
      t.timestamps
    end
  end

  def self.down
    remove_column :employments, :shift_id, :integer
    drop_table :employee_shifts
  end
end

