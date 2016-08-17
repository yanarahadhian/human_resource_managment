class AddImportedToRawPresences < ActiveRecord::Migration
  def self.up
    add_column  :raw_presences, :is_imported, :boolean, :default => false
  end

  def self.down
    remove_column  :raw_presences, :is_imported
  end
end
