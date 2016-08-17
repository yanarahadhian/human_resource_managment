class AddCompanyIdToSalaryMasterData < ActiveRecord::Migration
  def self.up
    add_column :salary_master_datas, :company_id, :integer
  end

  def self.down
    remove_column :salary_master_datas, :company_id
  end
end
