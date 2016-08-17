class DropShiftGroupOptions < ActiveRecord::Migration
  def self.up
		drop_table :shift_group_options	
  end

  def self.down
  end
end
