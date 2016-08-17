class AddIsActedUponToPresences < ActiveRecord::Migration
  def self.up
    add_column :presences, :is_acted_upon, :integer
    remove_column :presence_details, :is_acted_upon
  end

  def self.down
    add_column :presence_details, :is_acted_upon, :boolean
    remove_column :presences, :is_acted_upon
  end
end

