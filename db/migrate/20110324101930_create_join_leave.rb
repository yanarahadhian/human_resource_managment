class CreateJoinLeave < ActiveRecord::Migration
  def self.up
    create_table :join_leave do |t|
      t.references :company
      t.date :leave_date
      t.string :leave_name
      t.timestamps
    end
  end

  def self.down
    drop_table :join_leave
  end
end
