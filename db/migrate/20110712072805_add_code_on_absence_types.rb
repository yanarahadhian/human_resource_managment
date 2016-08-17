class AddCodeOnAbsenceTypes < ActiveRecord::Migration
  def self.up
    add_column :absence_types, :absence_type_code, :string
  end

  def self.down
    remove_column :absence_types, :code
  end
end
