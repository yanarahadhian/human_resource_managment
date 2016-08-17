class ChangeDateToIntForExperiences < ActiveRecord::Migration
  def self.up
    remove_column :experiences, :start_date
    remove_column :experiences, :end_date
    add_column :experiences, :start_date, :integer
    add_column :experiences, :end_date, :integer
  end

  def self.down
    remove_column :experiences, :start_date, :date
    remove_column :experiences, :end_date, :date
    add_column :experiences, :start_date
    add_column :experiences, :end_date
  end
end
