class CreatePositions < ActiveRecord::Migration
  def self.up
    create_table :positions do |t|
      t.references :company
      t.references :division
      t.string :position_name
      t.string :position_code
      t.timestamps
    end
  end

  def self.down
    drop_table :positions
  end
end

