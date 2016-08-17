class CreateWorkUnit < ActiveRecord::Migration
  def self.up
    create_table :work_units do |t|
      t.references :company
      t.references :division
      t.string :work_unit_name
      t.timestamps
    end
  end

  def self.down
    drop_table :work_units
  end
end
