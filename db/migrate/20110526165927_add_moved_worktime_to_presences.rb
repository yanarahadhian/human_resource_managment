class AddMovedWorktimeToPresences < ActiveRecord::Migration
  def self.up
    add_column :presences, :moved_worktime_in_hours, :decimal, :precision => 8, :scale => 4
  end

  def self.down
    remove_column :presences, :moved_worktime_in_hours
  end
end

