class AddHoldingCompanyIdToDivisions < ActiveRecord::Migration
  def self.up
    add_column :divisions, :holding_company_id, :integer
  end

  def self.down
    remove_column :divisions, :holding_company_id
  end
end
