class AddLiveTogetherToFamilies < ActiveRecord::Migration
  def self.up
    add_column :families, :live_together, :string
  end

  def self.down
    remove_column :families, :live_together
  end
end
