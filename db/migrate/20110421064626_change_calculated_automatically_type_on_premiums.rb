class ChangeCalculatedAutomaticallyTypeOnPremiums < ActiveRecord::Migration
  def self.up
  	change_table :premiums do |t|
  		t.change :calculated_automatically, :boolean
  	end
	end

  def self.down
  	 change_table :premiums do |t|
  		t.change :calculated_automatically, :decimal
  	end
  end
end
