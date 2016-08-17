class FixingColumnNameEmploymentTable < ActiveRecord::Migration
  def self.up
    rename_column(:employments, :employee_indentification, :employee_identification)
  end

  def self.down
    rename_column(:employments, :employee_identification, :employee_indentification)
  end
end
