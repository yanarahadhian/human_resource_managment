class CreateFamilies < ActiveRecord::Migration
  def self.up
    create_table :families do |t|
      t.integer   :person_id
      t.string    :relationship_to_person
      t.string    :full_name
      t.string    :gender
      t.string    :city_of_birth
      t.date      :date_of_birth
      t.string    :current_job
      t.string    :highest_education
      t.timestamps
    end
  end

  def self.down
    drop_table :families
  end
end
