class ChangeTypeDataOnPresenceDetails < ActiveRecord::Migration
  def self.up
    change_column :presence_details, :start_working, :datetime
    change_column :presence_details, :end_working, :datetime
  end

  def self.down
    change_column :presence_details, :start_working, :time
    change_column :presence_details, :end_working, :time
  end
end

