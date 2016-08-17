class CreateRawPresences < ActiveRecord::Migration
  def self.up
    create_table :raw_presences do |t|
      t.integer   :reg_id
      t.timestamp :presence_time
      t.integer   :status
      t.integer   :company_id
      t.timestamps
    end
  end

  def self.down
    drop_table :raw_presences
  end
end
