class CreatePresence < ActiveRecord::Migration
  def self.up
    create_table :presence do |t|
      t.references :company
      t.references :people
      t.date :presence_date
      t.integer :presence_length_in_hours
      t.integer :paid_hours
      t.integer :break_length_in_minutes
      t.string :presence_status
      t.string :presence_description
      t.timestamps
    end
  end

  def self.down
    drop_table :presence
  end
end
