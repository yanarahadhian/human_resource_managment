class AddAccountToPerson < ActiveRecord::Migration
  def self.up
     add_column :people, :bca_account_name, :string
     add_column :people, :bca_account_number, :string
  end

  def self.down
    remove_column :people, :bca_account_name
    remove_column :people, :bca_account_number
  end
end
