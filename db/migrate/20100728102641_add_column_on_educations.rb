class AddColumnOnEducations < ActiveRecord::Migration
  def self.up
    add_column :educations, :pendidikan_terakhir, :string
    add_column :educations, :no_ijazah, :string
  end

  def self.down
    remove_column :educations, :pendidikan_terakhir
    remove_column :educations, :no_ijazah
  end
end
