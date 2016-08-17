class CreateWorkGroup < ActiveRecord::Migration
  def self.up
    create_table :work_groups do |t|
      t.references :company
      t.references :work_unit
      t.string :work_group_name
      t.timestamps
    end
  end

  def self.down
    drop_table :work_groups
  end
end
