class AddColumnsOnTrainings < ActiveRecord::Migration
  def self.up
    add_column :trainings, :training_type, :string
    add_column :trainings, :promoter, :string
    add_column :trainings, :promoter_address, :string
    add_column :trainings, :promoter_phone, :string
    add_column :trainings, :theme, :string
    add_column :trainings, :certificate_number, :string
  end

  def self.down
    remove_column :trainings, :training_type
    remove_column :trainings, :promoter
    remove_column :trainings, :promoter_address
    remove_column :trainings, :promoter_phone
    remove_column :trainings, :theme
    remove_column :trainings, :certificate_number
  end
end
