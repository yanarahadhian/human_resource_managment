class AddJamsostekNumberOnPeople < ActiveRecord::Migration
 def self.up
    add_column :people, :jamsostek_number, :string
  end

  def self.down
    remove_column :people, :jamsostek_number
  end
end
