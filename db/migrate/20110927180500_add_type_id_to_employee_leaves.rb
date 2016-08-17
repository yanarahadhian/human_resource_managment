class AddTypeIdToEmployeeLeaves < ActiveRecord::Migration
  def self.up
    add_column :employee_leaves, :type_id, :integer
    add_index :employee_leaves, :type_id
  end

  def self.down
    remove_index :employee_leaves, :type_id
    remove_column :employee_leaves, :type_id
  end
end
