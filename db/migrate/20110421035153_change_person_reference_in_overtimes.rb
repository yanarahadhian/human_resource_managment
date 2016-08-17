class ChangePersonReferenceInOvertimes < ActiveRecord::Migration
  def self.up
    rename_column(:overtimes, :people_id, :person_id)
    rename_column(:absences, :people_id, :person_id)
    rename_column(:presences, :people_id, :person_id)
  end

  def self.down
    rename_column(:overtimes, :person_id, :people_id)
    rename_column(:absences, :person_id, :people_id)
    rename_column(:presences, :person_id, :people_id)
  end
end

