class AddRelasiToKontakDarurat < ActiveRecord::Migration
  def self.up
    add_column :people, :relasi_kontak_darurat, :string
  end

  def self.down
    remove_column :people, :relasi_kontak_darurat
  end
end
