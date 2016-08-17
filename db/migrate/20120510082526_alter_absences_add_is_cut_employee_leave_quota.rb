class AlterAbsencesAddIsCutEmployeeLeaveQuota < ActiveRecord::Migration

  def self.up
    add_column :absences, :is_cut_employee_leave_quota, :boolean
  end

  def self.down
    remove_column :absences, :is_cut_employee_leave_quota
  end

end
