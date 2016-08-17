class CreateShiftGroupOptions < ActiveRecord::Migration
  def self.up
    create_table :shift_group_options do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :shift_group_options
  end
end
