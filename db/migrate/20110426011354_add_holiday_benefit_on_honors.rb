class AddHolidayBenefitOnHonors < ActiveRecord::Migration
  def self.up
  	add_column :honors, :holiday_benefits, :decimal, :precision => 12, :scale => 2
	end

  def self.down
  	remove_column :honors, :holiday_benefits
  end
end