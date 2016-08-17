class CreateEmployments < ActiveRecord::Migration
  def self.up
    create_table :employments do |t|
      t.references :person 
      t.references :department
      t.references :employment_type
      t.references :work_unit
      t.references :work_group
      t.references :position
      t.integer    :work_division_id
      t.boolean    :head_division 
      t.boolean    :head_department
      t.date       :employment_start
      t.date       :employment_end
      t.string     :work_assigned
      t.string     :shift
      t.string     :employee_indentification
      t.string     :change_from_before
      t.text       :reason_for_change
      t.integer    :previous_employment_id
      t.timestamps
    end
  end

  def self.down
    drop_table :employments
  end
end
