class CreateEmploymentHistories < ActiveRecord::Migration
  def self.up
    create_table :employment_histories do |t|
      t.references :person
      t.references :company
      t.references :division
      t.references :position
      t.date :start
      t.date :finish
      t.timestamps
    end
  end

  def self.down
    drop_table :employment_histories
  end
end
