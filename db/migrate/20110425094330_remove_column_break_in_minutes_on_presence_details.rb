class RemoveColumnBreakInMinutesOnPresenceDetails < ActiveRecord::Migration
  def self.up
    remove_column :presence_details, :break_in_minutes
  end

  def self.down
    add_column :presence_details, :break_in_minutes, :integer
  end
end

