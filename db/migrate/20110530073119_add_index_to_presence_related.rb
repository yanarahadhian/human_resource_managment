class AddIndexToPresenceRelated < ActiveRecord::Migration
  def self.up
    add_index :presences, :company_id
    add_index :presences, :person_id
    add_index :presences, :presence_date
    add_index :presences, :presence_length_in_hours
    add_index :presences, :break_length_in_minutes
    add_index :presence_details, :presence_id
    add_index :presence_details, :start_working
    add_index :presence_details, :end_working
    add_index :employments, :person_id
    add_index :employments, :department_id
    add_index :employments, :work_group_id
    add_index :employments, :work_division_id
    add_index :employments, :employment_start
    add_index :shifts, :company_id
    add_index :employee_leaves, :company_id
    add_index :employee_leaves, :person_id
    add_index :absences, :company_id
    add_index :absences, :person_id
    add_index :absences, :absence_date
    add_index(:people, [:firstname, :lastname], :name => 'full_name', :length => 16)

#    add_index(:accounts, :name, :limit => 10)
  end

  def self.down
    remove_index :presences, :company_id
    remove_index :presences, :person_id
    remove_index :presences, :presence_date
    remove_index :presences, :presence_length_in_hours
    remove_index :presences, :break_length_in_minutes
    remove_index :presence_details, :presence_id
    remove_index :presence_details, :start_working
    remove_index :presence_details, :end_working
    remove_index :employments, :person_id
    remove_index :employments, :department_id
    remove_index :employments, :work_group_id
    remove_index :employments, :work_division_id
    remove_index :employments, :employment_start
    remove_index :shifts, :company_id
    remove_index :employee_leaves, :company_id
    remove_index :employee_leaves, :person_id
    remove_index :absences, :company_id
    remove_index :absences, :person_id
    remove_index :absences, :absence_date
    remove_index(:people, :name => 'full_name')
  end
end

