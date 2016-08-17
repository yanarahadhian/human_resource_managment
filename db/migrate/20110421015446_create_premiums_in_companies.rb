class CreatePremiumsInCompanies < ActiveRecord::Migration
  def self.up
    create_table :premiums_in_companies do |t|
      t.integer :company_id
      t.integer :premium_id
      t.boolean :calculated_on_overtime
      t.boolean :calculated_on_salary_cut
      t.timestamps
    end
  end

  def self.down
    drop_table :premiums_in_companies
  end
end
