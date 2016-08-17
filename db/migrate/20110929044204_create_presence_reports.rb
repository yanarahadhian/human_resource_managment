class CreatePresenceReports < ActiveRecord::Migration
  def self.up
    create_table :presence_reports, :id => false do |t|
      t.integer :presence_id
      t.integer :absence_id
      t.integer :company_id
      t.integer :department_id
      t.integer :division_id
      t.integer :person_id
      t.string  :employee_id
      t.date    :date
      t.boolean :is_holiday
      t.string  :full_name, :limit => 80
      t.string  :department_name, :limit => 50
      t.string  :division_name, :limit => 50
      t.string  :absence_code, :limit => 10
      t.float   :work_duration
      t.float   :overtime_duration
      t.timestamps
    end
    add_index :presence_reports, :presence_id
    add_index :presence_reports, :absence_id
    add_index :presence_reports, :person_id
    add_index :presence_reports, :employee_id
    add_index :presence_reports, :company_id
    add_index :presence_reports, :department_id
    add_index :presence_reports, :division_id
    add_index :presence_reports, :updated_at
    add_index :presence_reports, [:person_id, :date], :unique => true
    add_index :presences, :updated_at
    add_index :absences, :updated_at
  end

  def self.down
    remove_index :presences, :updated_at
    remove_index :absences, :updated_at
    drop_table :presence_reports
  end
end
