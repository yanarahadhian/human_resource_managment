class RemoveShiftOptionIdOnEmployments < ActiveRecord::Migration
  def self.up
  	remove_column :employments, :shift_option_id
  end

  def self.down
  	add_column :employments, :shift_option_id, :integer
  end
end