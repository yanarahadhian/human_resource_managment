class DropShiftNormalOptions < ActiveRecord::Migration
  def self.up
  	drop_table :shift_normal_options
  end

  def self.down
  end
end
