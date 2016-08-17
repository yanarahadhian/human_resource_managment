class CreatePersonRecurringSicks < ActiveRecord::Migration
  def self.up
    create_table :person_recurring_sicks do |t|
      t.integer :person_id
      t.date :first_time_sick_date
      t.date :first_presence_date_after_sick
      t.integer :length_sick
      t.timestamps
    end
  end

  def self.down
    drop_table :person_recurring_sicks
  end
end
