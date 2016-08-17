class RenameTableCompaniesIdOnHonors < ActiveRecord::Migration
  def self.up
  	rename_column :honors, :companies_id, :company_id
  end

  def self.down
  	rename_column :honors, :company_id, :companies_id
  end
end