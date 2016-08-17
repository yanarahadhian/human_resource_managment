class CreatePremia < ActiveRecord::Migration
  def self.up
  	create_table :premia do |t|
      t.reference :company
      t.string :premium_name
      t.integer :calculated_automatically
      t.integer :company_id	
      t.integer :calculated_on_overtime	
      t.integer :calculated_on_salary_cut
      t.timestamps
    end
  end

  def self.down
  end
end
