class AddCompanyIdToSeveralPages < ActiveRecord::Migration
  def self.up
     add_column :accidents, :company_id, :integer
     add_column :actions, :company_id, :integer
     add_column :addresses, :company_id, :integer
     add_column :awards, :company_id, :integer
     add_column :companies, :company_id, :integer
     add_column :correlations, :company_id, :integer
     add_column :educational_institutions, :company_id, :integer
     add_column :educations, :company_id, :integer
     add_column :families, :company_id, :integer
     add_column :features, :company_id, :integer
     add_column :holding_companies, :company_id, :integer
     add_column :sections, :company_id, :integer
     add_column :shift_group_options, :company_id, :integer
     add_column :shift_normal_options, :company_id, :integer
     add_column :users, :company_id, :integer
     add_column :violations, :company_id, :integer
  end

  def self.down
    remove_column :accidents, :company_id
    remove_column :actions, :company_id
    remove_column :addresses, :company_id
    remove_column :awards, :company_id
    remove_column :companies, :company_id
    remove_column :correlations, :company_id
    remove_column :educational_institutions, :company_id
    remove_column :educations, :company_id
    remove_column :families, :company_id
    remove_column :features, :company_id
    remove_column :holding_companies, :company_id
    remove_column :sections, :company_id
    remove_column :shift_group_options, :company_id
    remove_column :shift_normal_options, :company_id
    remove_column :users, :company_id
    remove_column :violations, :company_id
  end
end
