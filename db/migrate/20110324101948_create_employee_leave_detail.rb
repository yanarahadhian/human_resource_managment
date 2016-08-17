class CreateEmployeeLeaveDetail < ActiveRecord::Migration
  def self.up
    create_table :employee_leave_detail do |t|
      t.reference :employee_leave
      t.date :leave_date
      t.string :leave_description
      t.timestamps
    end
  end

  def self.down
    drop_table :employee_leave_detail
  end
end
