class ChangeShiftOnEmployments < ActiveRecord::Migration
  def self.up
  	rename_column :employments, :shift, :shift_id
  end

  def self.down
  	rename_column :employments, :shift, :shift_id
  end
end
