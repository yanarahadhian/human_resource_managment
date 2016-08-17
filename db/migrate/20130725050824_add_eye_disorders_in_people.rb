class AddEyeDisordersInPeople < ActiveRecord::Migration
  def self.up
  	add_column :people, :left_minus, :decimal, :default => 0
  	add_column :people, :right_minus, :decimal, :default => 0
  	add_column :people, :left_plus, :decimal, :default => 0
  	add_column :people, :right_plus, :decimal, :default => 0
  	add_column :people, :left_silinder, :decimal, :default => 0
  	add_column :people, :right_silinder, :decimal, :default => 0
  end

  def self.down
  	remove_column :people, :left_minus, :decimal
  	remove_column :people, :right_minus, :decimal
  	remove_column :people, :left_plus, :decimal
  	remove_column :people, :right_plus, :decimal
  	remove_column :people, :left_silinder, :decimal
  	remove_column :people, :right_silinder, :decimal
  end
end
