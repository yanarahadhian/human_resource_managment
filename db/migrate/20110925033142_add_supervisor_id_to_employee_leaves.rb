class AddSupervisorIdToEmployeeLeaves < ActiveRecord::Migration
  def self.up
    add_column :employee_leaves, :supervisor_id, :integer
    add_column :employee_leaves, :leave_status, :string
  end

  def self.down
    remove_column :employee_leaves, :supervisor_id
    remove_column :employee_leaves, :leave_status
  end
end
