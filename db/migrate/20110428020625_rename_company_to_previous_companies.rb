class RenameCompanyToPreviousCompanies < ActiveRecord::Migration
  def self.up
    rename_table :companies, :previous_companies
  end

  def self.down
    rename_table :previous_companies, :companies
  end
end
