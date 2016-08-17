class CreatePeopleTaxStatuses < ActiveRecord::Migration
  def self.up
    create_table :people_tax_statuses do |t|
      t.integer :person_id
      t.integer :tax_status_id
      t.date :tax_status_start
      t.timestamps
    end
  end

  def self.down
    drop_table :people_tax_statuses
  end
end
