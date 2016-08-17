class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string    :full_name
      t.string    :gender
      t.string    :city_of_birth
      t.date      :date_of_birth
      t.string    :religion
      t.string    :ethnicity
      t.string    :marital_status
      t.string    :blood_type
      t.float     :height_in_cm
      t.float     :weight_in_kg
      t.string    :color_blind, :limit => 10
      t.string    :blood_type, :limit => 2
      t.float     :height_in_cm
      t.float     :weight_in_kg
      t.text      :known_illnesses
      t.integer   :latest_employment_id
      t.string    :employment_status
      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
