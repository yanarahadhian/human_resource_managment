class CreateTrainings < ActiveRecord::Migration
  def self.up
    create_table :trainings do |t|
      t.integer   :person_id
      t.text      :training_description
      t.date      :training_start
      t.date      :training_end
      t.string    :person_trained_as
      t.string    :person_trained_in
      t.timestamps
    end
  end

  def self.down
    drop_table :trainings
  end
end
