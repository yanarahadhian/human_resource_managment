class AddTemaOnExperiences < ActiveRecord::Migration
  def self.up
    add_column :experiences, :tema, :string
  end

  def self.down
    remove_column :experiences, :tema
  end
end
