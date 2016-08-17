class CreateWarningMemo < ActiveRecord::Migration
  def self.up
    create_table :warning_memo do |t|
      t.reference :company
      t.reference :person
      t.string :memo_level
      t.string :warning_reason
      t.date :warning_date
      t.timestamps
    end
  end

  def self.down
    drop_table :warning_memo
  end
end
