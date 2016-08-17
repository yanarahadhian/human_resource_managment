class AddStartDateAndEndDateToSalaryMasterData < ActiveRecord::Migration
  def self.up
    add_column :salary_master_datas, :valid_from, :date
    add_column :salary_master_datas, :valid_to, :date
  end

  def self.down
    remove_column :salary_master_datas, :valid_from
    remove_column :salary_master_datas, :valid_to
  end
end
