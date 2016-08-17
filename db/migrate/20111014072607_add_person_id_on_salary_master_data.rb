class AddPersonIdOnSalaryMasterData < ActiveRecord::Migration
  def self.up
    add_column :salary_master_datas, :person_id, :integer
  end

  def self.down
    remove_column :salary_master_datas, :person_id
  end
end
