class AddActsAsArchive < ActiveRecord::Migration
  def self.up
    ActsAsArchive.update Person
  end

  def self.down
  end
end
