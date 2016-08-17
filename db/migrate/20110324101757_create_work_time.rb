class CreateWorkTime < ActiveRecord::Migration
  def self.up
    create_table :work_time do |t|
      t.references :company
      t.timestamp :start_time
      t.timestamp :end_time
      t.integer :length_in_hours
      t.integer :break_length_in_minutes
      t.integer :break_length_in_percentage
      t.integer :compulsory_overtime_in_minutes
      t.timestamps
    end
  end

  def self.down
    drop_table :work_time
  end
end
