class RemoveReplaceableAtAbsenceQuotas < ActiveRecord::Migration
  def self.up
    remove_column :absence_quotas, :replaceable
  end

  def self.down
    add_column :absence_quotas, :replaceable, :integer
  end
end
