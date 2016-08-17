class DropEmployeeLeaveDetails < ActiveRecord::Migration
  def self.up
  	drop_table :employee_leave_details
  end

  def self.down
  end
end
