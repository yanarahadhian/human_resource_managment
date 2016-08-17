class ChangesOnEmployeeLeaves < ActiveRecord::Migration
  def self.up
  	remove_column :employee_leaves, :quota_in_the_year
  	remove_column :employee_leaves, :year
  	remove_column :employee_leaves, :redeem_date
  	add_column :employee_leaves, :leave_date, :date,:after => :person_id
  	add_column :employee_leaves, :leave_description, :date
  end

  def self.down
  	add_column :employee_leaves, :quota_in_the_year, :integer
  	add_column :employee_leaves, :year, :integer
  	add_column :employee_leaves, :redeem_date, :date
  	remove_column :employee_leaves, :leave_date
  	remove_column :employee_leaves, :leave_description
  end
end