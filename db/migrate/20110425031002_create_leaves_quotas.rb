class CreateLeavesQuotas < ActiveRecord::Migration
  def self.up
    create_table :leaves_quotas do |t|
    	t.integer :company_id
    	t.integer :quota
    	t.date :start_date
    	t.date :end_date
    	t.date :redeem_date
      t.timestamps
    end
  end

  def self.down
    drop_table :leaves_quotas
  end
end
