class AlterHonorsChangeHonorYearType < ActiveRecord::Migration
  def self.up
    change_column :honors, :honor_year, :integer
  end

  def self.down
    change_column :honors, :honor_year, :year
  end
end
