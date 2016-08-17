class ChangePaidHoursOnPresences < ActiveRecord::Migration
  def self.up
    change_column :presences, :paid_hours, :decimal, :precision => 8, :scale => 4
    change_column :presences, :presence_length_in_hours, :decimal, :precision => 8, :scale => 4
  end

  def self.down
    change_column :presences, :paid_hours, :integer
    change_column :presences, :presence_length_in_hours, :decimal, :precision => 6, :scale => 2
  end
end

