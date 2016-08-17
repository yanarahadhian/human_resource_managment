class CreateAwards < ActiveRecord::Migration
  def self.up
    create_table :awards do |t|
      t.string    :award_name
      t.date      :award_date
      t.string    :period_type
      t.integer   :period_id
      t.timestamps
    end
  end

  def self.down
    drop_table :awards
  end
end
