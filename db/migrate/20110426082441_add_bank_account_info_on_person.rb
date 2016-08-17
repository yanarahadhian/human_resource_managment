class AddBankAccountInfoOnPerson < ActiveRecord::Migration
  def self.up
  	add_column :people, :bank_name, :string
  	add_column :people, :account_name, :string
  	add_column :people, :account_number, :string
  end

  def self.down
  	remove_column :people, :bank_name
  	remove_column :people, :account_name
  	remove_column :people, :account_number
  end
end

