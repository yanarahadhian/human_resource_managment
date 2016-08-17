class CreateCorrelations < ActiveRecord::Migration
  def self.up
    create_table :correlations do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :correlations
  end
end
