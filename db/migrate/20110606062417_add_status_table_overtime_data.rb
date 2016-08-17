class AddStatusTableOvertimeData < ActiveRecord::Migration
  def self.up
    add_column :overtime_datas, :status, :string
  end

  def self.down
    remove_column :overtime_datas, :status
  end
end
