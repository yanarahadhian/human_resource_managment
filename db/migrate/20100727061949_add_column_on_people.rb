class AddColumnOnPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :no_npwp, :string
    add_column :people, :no_hp, :string
    add_column :people, :nama_kontak_darurat, :string
    add_column :people, :no_telp_kontak_darurat, :string
  end

  def self.down
    remove_column :people, :no_npwp
    remove_column :people, :no_hp
    remove_column :people, :nama_kontak_darurat
    remove_column :people, :no_telp_kontak_darurat
  end
end
