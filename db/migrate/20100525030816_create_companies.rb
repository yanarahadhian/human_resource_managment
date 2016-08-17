class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string    :company_name
      t.string    :company_industry
      t.timestamps
    end
  end

  def self.down
    drop_table :companies
  end
end
