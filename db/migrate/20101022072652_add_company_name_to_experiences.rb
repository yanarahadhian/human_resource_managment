class AddCompanyNameToExperiences < ActiveRecord::Migration
  def self.up
    add_column :experiences, :company_name, :string
  end

  def self.down
    remove_column :experiences, :company_name
  end
end
