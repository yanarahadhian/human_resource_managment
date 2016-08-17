class RemoveReplaceableFromAbsenceType < ActiveRecord::Migration
  def self.up
    remove_column :absence_types, :replaceable
  end

  def self.down
    add_column :absence_types, :replaceable, :boolean
  end
end
