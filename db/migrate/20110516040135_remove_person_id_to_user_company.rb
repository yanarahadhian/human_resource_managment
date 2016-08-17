class RemovePersonIdToUserCompany < ActiveRecord::Migration
  def self.up
    remove_column :user_companies, :person_id
  end

  def self.down
    add_column :user_companies, :person_id, :integer
  end
end
