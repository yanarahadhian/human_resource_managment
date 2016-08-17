class AddOvertimeDescriptionToOvertimes < ActiveRecord::Migration
  def self.up
    add_column :overtimes, :overtime_description, :string
  end

  def self.down
    remove_column :overtimes, :overtime_description
  end
end

