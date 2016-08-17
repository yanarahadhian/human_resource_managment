class ChangeStartEndPeriodeInOvertimeData < ActiveRecord::Migration
  def self.up
    change_column :overtime_datas, :start_periode, :date
    change_column :overtime_datas, :end_periode, :date
  end

  def self.down
    change_column :overtime_datas, :start_periode, :time
    change_column :overtime_datas, :end_periode, :time
  end
end
