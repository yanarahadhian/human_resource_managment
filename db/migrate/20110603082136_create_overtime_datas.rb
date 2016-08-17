class CreateOvertimeDatas < ActiveRecord::Migration
  def self.up
    create_table :overtime_datas do |t|
      t.integer :person_id
      t.integer :division_id
      t.integer :work_group_id
      t.time :start_overtime
      t.string :reason
      t.time :start_periode
      t.time :end_periode
      t.timestamps
    end
  end

  def self.down
    drop_table :overtime_datas
  end
end
