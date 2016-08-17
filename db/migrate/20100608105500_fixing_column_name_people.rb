class FixingColumnNamePeople < ActiveRecord::Migration
  def self.up
    rename_column(:people, :date_of_birth, :birth_date)
  end

  def self.down
    rename_column(:people, :birth_date, :date_of_birth)
  end
end
