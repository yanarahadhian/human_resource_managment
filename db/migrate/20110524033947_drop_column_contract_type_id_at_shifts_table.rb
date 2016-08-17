class DropColumnContractTypeIdAtShiftsTable < ActiveRecord::Migration
  def self.up
    remove_column :shifts, :contract_type_id
  end

  def self.down
    add_column :shifts, :contract_type_id, :integer
  end
end
