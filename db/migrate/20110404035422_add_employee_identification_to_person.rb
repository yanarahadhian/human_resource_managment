class AddEmployeeIdentificationToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :employee_identification_number, :string
  end

  def self.down
    remove_column :people, :employee_identification_number
  end
end
