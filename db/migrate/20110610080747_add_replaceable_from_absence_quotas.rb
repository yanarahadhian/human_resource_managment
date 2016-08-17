class AddReplaceableFromAbsenceQuotas < ActiveRecord::Migration
  def self.up
    add_column :absence_quotas, :replaceable, :integer
  end

  def self.down
    remove_column :absence_quotas, :replaceable
  end
end
