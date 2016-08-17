class CreateHealthDetails < ActiveRecord::Migration
  def self.up
    create_table :health_details do |t|
      t.references :health
      t.string :disease_name
      t.date :start
      t.date :finish
      t.string :disease_efect
      t.string :reduction
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :health_details
  end
end
