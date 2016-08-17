class AddPreviousWorkContractIdToWorkContract < ActiveRecord::Migration
  def self.up
    add_column :work_contracts, :previous_work_contract_id, :integer
  end

  def self.down
    remove_column :work_contracts, :previous_work_contract_id, :integer
  end
end
