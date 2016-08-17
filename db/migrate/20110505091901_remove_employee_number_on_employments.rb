class RemoveEmployeeNumberOnEmployments < ActiveRecord::Migration
  def self.up
    remove_column :employments, :employee_number
  end

  def self.down
    add_column :employments, :employee_number, :string
  end
end