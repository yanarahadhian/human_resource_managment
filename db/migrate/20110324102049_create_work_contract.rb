class CreateWorkContract < ActiveRecord::Migration
  def self.up
    create_table :work_contract do |t|
      t.references :company
      t.references :person
      t.references :contract_type
      t.date :contract_start
      t.date :contract_end
      t.timestamps
    end
  end

  def self.down
    drop_table :work_contract
  end
end
