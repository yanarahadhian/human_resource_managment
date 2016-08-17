class CreateViolations < ActiveRecord::Migration
  def self.up
    create_table :violations do |t|
      t.integer   :person_id
      t.string    :violation_category
      t.text      :violation_description
      t.date      :occurence_date
      t.string    :occurence_location
      t.integer   :person_in_charge
      t.string    :action_taken
      t.date      :action_until
      t.timestamps
    end
  end

  def self.down
    drop_table :violations
  end
end
