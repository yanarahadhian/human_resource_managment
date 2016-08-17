class AddColumnOnAddress < ActiveRecord::Migration
  def self.up
    add_column :addresses, :rt, :string
    add_column :addresses, :rw, :string
    add_column :addresses, :kecamatan, :string
    add_column :addresses, :kelurahan, :string
    add_column :addresses, :kode_pos, :string
    add_column :addresses, :no_telp, :string
  end

  def self.down
    remove_column :addresses, :rt
    remove_column :addresses, :rw
    remove_column :addresses, :kecamatan
    remove_column :addresses, :kelurahan
    remove_column :addresses, :kode_pos
    remove_column :addresses, :no_telp
  end
end
