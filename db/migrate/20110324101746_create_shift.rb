class CreateShift < ActiveRecord::Migration
  def self.up
    create_table :shift do |t|
      t.references :company
      t.string :shift_name
      t.references :monday_time
      t.references :tuesday_time
      t.references :wednesday_time
      t.references :thursday_time
      t.references :friday_time
      t.references :saturday_time
      t.references :sunday_time
      t.string :shift_category
      t.timestamps
    end
  end

  def self.down
    drop_table :shift
  end
end
