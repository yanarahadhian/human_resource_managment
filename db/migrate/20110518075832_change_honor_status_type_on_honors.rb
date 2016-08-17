class ChangeHonorStatusTypeOnHonors < ActiveRecord::Migration
  def self.up
    change_column :honors, :honor_status, :string
  end

  def self.down
    change_column :honors, :honor_status, :decimal
  end
end


