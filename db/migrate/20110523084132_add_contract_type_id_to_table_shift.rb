class AddContractTypeIdToTableShift < ActiveRecord::Migration
  def self.up
    add_column :shifts, :contract_type_id, :integer
  end

  def self.down
    remove_column :shifts, :contract_type_id
  end
end
