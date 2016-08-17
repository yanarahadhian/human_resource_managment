class CreateSalaryMasterDataHistories < ActiveRecord::Migration
  def self.up
    create_table :salary_master_data_histories do |t|
      t.references :salary_master_data
      t.integer :employment_id
      t.decimal :basic_salary, :precision => 12, :scale => 2
      t.decimal :cooperation_cut, :precision => 12, :scale => 2
      t.integer :company_id
      t.integer :person_id
      t.timestamps
    end
  end

  def self.down
    drop_table :salary_master_data_histories
  end
end
