class RenamePeopleIdOnHonors < ActiveRecord::Migration
  def self.up
  	rename_column :honors, :people_id, :person_id
  end

  def self.down
  	rename_column :honors, :person_id, :people_id
  end
end