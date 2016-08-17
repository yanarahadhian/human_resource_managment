class AddTokenStringToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :token_string, :string
  end

  def self.down
    remove_column :people, :token_string
  end
end
