class CreateUserCompanies < ActiveRecord::Migration
  def self.up
    create_table :user_companies do |t|
      t.references :company
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :user_companies
  end
end
