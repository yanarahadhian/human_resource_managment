class CreateDownloadDataLogs < ActiveRecord::Migration
  def self.up
    create_table :download_data_logs do |t|
      t.integer   :company_id
      t.string    :end_time
      t.timestamps
    end
  end

  def self.down
    drop_table :download_data_logs
  end
end
