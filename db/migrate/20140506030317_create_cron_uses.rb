class CreateCronUses < ActiveRecord::Migration
  def self.up
    create_table :cron_uses do |t|
      t.string :company_id
      t.timestamps
    end
  end

  def self.down
    drop_table :cron_uses
  end
end
