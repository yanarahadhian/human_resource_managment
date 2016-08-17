class AddLatestWorkContractIdToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :latest_work_contract_id, :integer
  end

  def self.down
    remove_column :people, :latest_work_contract_id
  end
end
