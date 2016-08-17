class AddPersonIdToUserCompany < ActiveRecord::Migration
  def self.up
    add_column :user_companies, :person_id, :integer
  end

  def self.down
    remove_column :user_companies, :person_id
  end
end
