class CreateSalaryMasterDatas < ActiveRecord::Migration
  def self.up
    create_table :salary_master_datas do |t|
      t.integer :employment_id
      t.decimal :basic_salary, :precision => 12, :scale => 2
      t.decimal :cooperation_cut, :precision => 12, :scale => 2 	
      t.timestamps
    end
  end

  def self.down
    drop_table :salary_master_datas
  end
end
