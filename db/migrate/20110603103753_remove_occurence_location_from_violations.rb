class RemoveOccurenceLocationFromViolations < ActiveRecord::Migration
  def self.up
    remove_column :violations, :occurence_location
  end

  def self.down
    add_column :violations, :occurence_location, :string
  end
end
