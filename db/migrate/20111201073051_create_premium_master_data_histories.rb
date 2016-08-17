class CreatePremiumMasterDataHistories < ActiveRecord::Migration
  def self.up
    create_table :premium_master_data_histories do |t|
      t.references :salary_master_data_history
      t.integer :premiums_in_company_id
      t.decimal  :value, :precision => 12, :scale => 2
      t.timestamps
    end
  end

  def self.down
    drop_table :premium_master_data_histories
  end
end
