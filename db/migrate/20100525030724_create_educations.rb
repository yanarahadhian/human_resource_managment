class CreateEducations < ActiveRecord::Migration
  def self.up
    create_table :educations do |t|
      t.integer   :person_id
      t.integer   :educational_institution_id
      t.string    :field_major
      t.integer   :entry_year
      t.integer   :graduation_year
      t.float     :gpa
      t.text      :educational_description
      t.timestamps
    end
  end

  def self.down
    drop_table :educations
  end
end
