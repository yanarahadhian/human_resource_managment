class AddColumnOnExperiences < ActiveRecord::Migration
  def self.up
    add_column :experiences, :no_telp, :string
    add_column :experiences, :jenis_kerja, :string
  end

  def self.down
    remove_column :experiences, :no_telp
    remove_column :experiences, :jenis_kerja
  end
end
