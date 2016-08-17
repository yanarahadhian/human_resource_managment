class RemoveHonorDateOnHonors < ActiveRecord::Migration
  def self.up
  	remove_column :honors, :honor_date
	end

  def self.down
  	add_column :honors, :honor_date, :date
  end
end
