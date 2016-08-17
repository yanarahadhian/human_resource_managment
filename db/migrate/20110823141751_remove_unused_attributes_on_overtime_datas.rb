class RemoveUnusedAttributesOnOvertimeDatas < ActiveRecord::Migration
  def self.up
    remove_column :overtime_datas, :division_id
    remove_column :overtime_datas, :work_group_id
  end

  def self.down
    add_column :overtime_datas, :division_id, :integer
    add_column :overtime_datas, :work_group_id, :integer
  end
end
