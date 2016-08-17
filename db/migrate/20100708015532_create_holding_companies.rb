class CreateHoldingCompanies < ActiveRecord::Migration
  def self.up
    create_table :holding_companies do |t|
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :holding_companies
  end
end
