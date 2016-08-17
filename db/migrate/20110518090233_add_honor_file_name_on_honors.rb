class AddHonorFileNameOnHonors < ActiveRecord::Migration
  def self.up  
    add_column :honors, :file_name, :string
  end

  def self.down
    remove_column :honors, :file_name
  end
end
