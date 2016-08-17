class AddJamsostekNumberOnEmployments < ActiveRecord::Migration
  def self.up
  	add_column :employments, :jamsostek_number, :string
  	add_column :employments, :employee_number, :string
  end

  def self.down
  	remove_column :employments, :jamsostek_number
  	remove_column :employments, :employee_number
  end
end