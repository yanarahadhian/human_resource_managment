class AddWorkSessionLengthInMinutesOnPresenceDetails < ActiveRecord::Migration
  def self.up
    add_column :presence_details, :work_session_length_in_minutes, :integer
    change_column :presences, :presence_length_in_hours, :decimal, :precision => 6, :scale => 2
  end

  def self.down
    remove_column :presence_details, :work_session_length_in_minutes
    change_column :presences, :presence_length_in_hours, :integer
  end
end

