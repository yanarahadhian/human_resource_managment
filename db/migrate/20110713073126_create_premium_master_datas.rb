class CreatePremiumMasterDatas < ActiveRecord::Migration
  def self.up
    create_table :premium_master_datas do |t|
      t.integer :salary_master_data_id
      t.decimal :premiums_in_company_id
      t.decimal :value, :precision => 12, :scale => 2 
      t.timestamps
    end
  end

  def self.down
    drop_table :premium_master_datas
  end
end
