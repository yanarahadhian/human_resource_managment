class RemoveJamsostekNumberOnEmployments < ActiveRecord::Migration
  def self.up
    remove_column :employments, :jamsostek_number
  end

  def self.down
    add_column :employments, :jamsostek_number, :string
  end
end
