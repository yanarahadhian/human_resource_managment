class AddNoKtpOnPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :no_ktp, :string
  end

  def self.down
    remove_column :people, :no_ktp
  end
end
