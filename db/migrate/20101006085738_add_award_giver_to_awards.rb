class AddAwardGiverToAwards < ActiveRecord::Migration
  def self.up
    add_column :awards, :awards_giver, :string
  end

  def self.down
    remove_column :awards, :awards_giver
  end
end
