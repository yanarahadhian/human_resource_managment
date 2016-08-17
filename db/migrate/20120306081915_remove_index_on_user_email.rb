class RemoveIndexOnUserEmail < ActiveRecord::Migration
  def self.up
  	remove_index :users, :column => :email
  end

  def self.down
  	add_index :users, :email
  end
end