class AddAttributesOnAbsenceType < ActiveRecord::Migration
  def self.up
    add_column :absence_types, :company_id, :integer
    add_column :absence_types, :type_id, :integer
    add_column :absence_types, :quota, :integer
    add_column :absence_types, :replaceable, :boolean
    add_column :absence_types, :count_as_leave, :boolean
  end

  def self.down
    remove_column :absence_types, :company_id
    remove_column :absence_types, :type_id
    remove_column :absence_types, :quota
    remove_column :absence_types, :replaceable
    remove_column :absence_types, :count_as_leave
  end
end
