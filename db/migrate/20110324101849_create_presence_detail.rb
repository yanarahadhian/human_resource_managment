class CreatePresenceDetail < ActiveRecord::Migration
  def self.up
    create_table :presence_detail do |t|
      t.references :presence
      t.time :start_working
      t.time :end_working
      t.integer :break_in_minutes
      t.integer :lateness_in_minutes
      t.string :lateness_reason
      t.boolean :is_acted_upon
      t.timestamps
    end
  end

  def self.down
    drop_table :presence_detail
  end
end
