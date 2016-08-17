class AddIsActiveToEmployeeShifts < ActiveRecord::Migration
  def self.up
    add_column :employee_shifts, :is_active, :boolean

    EmployeeShift.reset_column_information
    people = Person.all
    people.each do |person|
      employee_shift = person.employee_shifts.find(:last, :order => :shift_from)
      employee_shift.update_attributes(:is_active => true) unless employee_shift.blank?
    end
  end

  def self.down
    remove_column :employee_shifts, :is_active
  end
end
