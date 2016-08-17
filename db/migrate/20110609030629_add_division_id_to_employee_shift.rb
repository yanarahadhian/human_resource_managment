class AddDivisionIdToEmployeeShift < ActiveRecord::Migration
  def self.up
    add_column :employee_shifts , :division_id, :integer
  end

  def self.down
    remove_column :employee_shifts , :division_id
  end
end
