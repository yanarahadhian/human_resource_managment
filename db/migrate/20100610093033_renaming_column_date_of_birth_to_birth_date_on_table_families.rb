class RenamingColumnDateOfBirthToBirthDateOnTableFamilies < ActiveRecord::Migration
  def self.up
    rename_column(:families, :date_of_birth, :birth_date)
  end

  def self.down
    rename_column(:families, :birth_date, :date_of_birth)
  end
end
