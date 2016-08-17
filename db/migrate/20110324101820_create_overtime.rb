class CreateOvertime < ActiveRecord::Migration
  def self.up
    create_table :overtime do |t|
      t.references :company
      t.references :people
      t.timestamp :start_overtime
      t.timestamp :end_overtime
      t.integer :overtime_length_in_minutes
      t.string :overtime_status
      t.timestamps
    end
  end

  def self.down
    drop_table :overtime
  end
end
