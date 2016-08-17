class CreateContractType < ActiveRecord::Migration
  def self.up
    create_table :contract_type do |t|
      t.references :company
      t.string :contract_type_name
      t.timestamps
    end
  end

  def self.down
    drop_table :contract_type
  end
end
