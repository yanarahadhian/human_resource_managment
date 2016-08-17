class ChangeColumnsTypeOnPremiums < ActiveRecord::Migration
 def self.up
  	change_table :premiums do |t|
  		t.change :calculated_on_overtime, :boolean
  		t.change :calculated_on_salary_cut, :boolean
  	end
	end

  def self.down
  	 change_table :premiums do |t|
  		t.change :calculated_on_overtime, :integer
  		t.change :calculated_on_salary_cut, :integer
  	end
  end
end