class RemoveFullNameToPerson < ActiveRecord::Migration
  def self.up
    remove_column :people, :full_name
  end

  def self.down
    add_column :people, :full_name, :string
  end
end
