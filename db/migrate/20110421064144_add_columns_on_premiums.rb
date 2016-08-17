class AddColumnsOnPremiums < ActiveRecord::Migration
  def self.up
  	add_column :premiums, :company_id, :integer
  	add_column :premiums, :calculated_on_overtime, :integer
  	add_column :premiums, :calculated_on_salary_cut, :integer
	end

  def self.down
  	remove_column :premiums, :company_id
  	remove_column :premiums, :calculated_on_overtime
  	remove_column :premiums, :calculated_on_salary_cut
  end
end
