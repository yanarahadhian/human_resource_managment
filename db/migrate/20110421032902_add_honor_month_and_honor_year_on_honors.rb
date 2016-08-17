class AddHonorMonthAndHonorYearOnHonors < ActiveRecord::Migration
  def self.up
  	add_column :honors, :honor_month, :integer
  	add_column :honors, :honor_year, :year
  end

  def self.down
  	remove_column :honors, :honor_month
  	remove_column :honors, :honor_year
  end
end