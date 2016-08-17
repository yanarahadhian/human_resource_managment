class AddPersonalEmailToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :personal_email, :string
  end

  def self.down
    remove_column :people, :personal_email
  end
end
