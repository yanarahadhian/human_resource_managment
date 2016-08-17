class RenameDivisionIdToWorkGroupIdAtEmployeeShift < ActiveRecord::Migration
  def self.up
    rename_column :employee_shifts , :division_id , :work_group_id
  end

  def self.down
    rename_column :employee_shifts , :work_group_id , :division_id
  end
end
