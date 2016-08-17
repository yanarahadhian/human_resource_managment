class AddTotalHoursAtShiftTable < ActiveRecord::Migration
  def self.up
    add_column :shifts, :total_hours, :integer
  end

  def self.down
    remove_column :shifts, :total_hours
  end
end
