class CreateAbsence < ActiveRecord::Migration
  def self.up
    create_table :absence do |t|
      t.references :company
      t.references :people
      t.time :absence_date
      t.references :absence_type
      t.string :absence_reason
      t.timestamps
    end
  end

  def self.down
    drop_table :absence
  end
end
