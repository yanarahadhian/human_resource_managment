class DropWorkUnitAndFixPositionsColumn < ActiveRecord::Migration
  def self.up
    begin drop_table :work_units rescue true end
    begin remove_column :work_groups, :work_unit_id rescue true end
    begin add_column :work_groups, :division_id, :integer rescue true end
    begin remove_column :employments, :work_unit_id rescue true end
    begin remove_column :positions, :division_id rescue true end
  end

  def self.down
    add_column :work_groups, :work_unit_id, :integer
    remove_column :work_groups, :division_id
    add_column :employments, :work_unit_id, :integer
    add_column :positions, :division_id
    create_table :work_units do |t|
      t.references :company
      t.references :division
      t.string :work_unit_name
      t.timestamps
    end
  end
end

