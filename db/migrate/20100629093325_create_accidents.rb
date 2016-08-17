class CreateAccidents < ActiveRecord::Migration
  def self.up
    create_table :accidents do |t|
      t.string :accident_location
      t.date :accident_date
      t.string :causes
      t.text :accident_description
      t.string :action_taken
      t.string :accident_category
      t.references :person

      t.timestamps
    end
    add_index :accidents, :person_id
    add_index :accidents, :accident_location
    add_index :accidents, :accident_category
  end

  def self.down
    drop_table :accidents
  end
end
