class AddHonorDateOnHonors < ActiveRecord::Migration
  def self.up
    add_column :honors, :honor_date, :date
  end

  def self.down
    remove_column :honors, :honor_date
  end
end
