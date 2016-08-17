class AddPrecisionForUnnormalEyesInPeople < ActiveRecord::Migration
  def self.up
  	change_table :people do |t|
 	  change_column :people, :left_minus, :decimal, :precision => 20, :scale => 2, :default => 0
 	  change_column :people, :right_minus, :decimal, :precision => 20, :scale => 2, :default => 0
 	  change_column :people, :left_plus, :decimal, :precision => 20, :scale => 2, :default => 0
 	  change_column :people, :right_plus, :decimal, :precision => 20, :scale => 2, :default => 0
 	  change_column :people, :left_silinder, :decimal, :precision => 20, :scale => 2, :default => 0
 	  change_column :people, :right_silinder, :decimal, :precision => 20, :scale => 2, :default => 0
    end
  end 

  def self.down
  	change_table :people do |t|
 	  change_column :people, :left_minus, :decimal, :default => 0
 	  change_column :people, :right_minus, :decimal, :default => 0
 	  change_column :people, :left_plus, :decimal, :default => 0
 	  change_column :people, :right_minus, :decimal,  :default => 0
 	  change_column :people, :left_silinder, :decimal, :default => 0
 	  change_column :people, :right_silinder, :decimal,  :default => 0
    end
  end 
end
