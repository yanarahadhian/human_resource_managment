class AddCompanyIdToTaxStatuses < ActiveRecord::Migration
  def self.up
    add_column :tax_statuses, :company_id, :integer
  end

  def self.down
    remove_column :tax_statuses, :company_id
  end
end
