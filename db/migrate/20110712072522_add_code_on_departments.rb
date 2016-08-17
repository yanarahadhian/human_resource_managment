class AddCodeOnDepartments < ActiveRecord::Migration
  def self.up
    add_column :departments, :department_code, :string
  end

  def self.down
    remove_column :departments, :code
  end
end
