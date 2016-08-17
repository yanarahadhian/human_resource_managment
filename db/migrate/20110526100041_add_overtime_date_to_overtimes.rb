class AddOvertimeDateToOvertimes < ActiveRecord::Migration
  def self.up
    add_column :overtimes, :overtime_date, :date
  end

  def self.down
    remove_column :overtimes, :overtime_date
  end
end

