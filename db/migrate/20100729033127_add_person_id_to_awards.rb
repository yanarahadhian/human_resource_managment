class AddPersonIdToAwards < ActiveRecord::Migration
  def self.up
    add_column :awards, :person_id, :string
  end

  def self.down
    remove_column :awards, :person_id
  end
end
