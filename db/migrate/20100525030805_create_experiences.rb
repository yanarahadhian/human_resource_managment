class CreateExperiences < ActiveRecord::Migration
  def self.up
    create_table :experiences do |t|
      t.string    :experience_type
      t.integer   :person_id
      t.integer   :company_id
      t.string    :division
      t.string    :position_held
      t.text      :job_description
      t.date      :start_date
      t.date      :end_date
      t.text      :reason_of_termination
      t.timestamps
    end
  end

  def self.down
    drop_table :experiences
  end
end
