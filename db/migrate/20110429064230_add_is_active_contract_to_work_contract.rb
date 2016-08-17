class AddIsActiveContractToWorkContract < ActiveRecord::Migration
  def self.up
    add_column :work_contracts, :is_active_contract, :boolean
  end

  def self.down
    remove_column :work_contracts, :is_active_contract
  end
end
