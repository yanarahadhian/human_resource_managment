class AddCreateValidToToSalaryMasterDataHistory < ActiveRecord::Migration
  def self.up
    add_column :salary_master_data_histories, :valid_from, :date
    add_column :salary_master_data_histories, :valid_to, :date
  end

  def self.down
    remove_column :salary_master_data_histories, :valid_from
    remove_column :salary_master_data_histories, :valid_to
  end
end
