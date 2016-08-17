class RenameTableJoinLeaves < ActiveRecord::Migration
  def self.up
  	rename_table :join_leaves, :joint_leaves
  end

  def self.down
  	rename_table :joint_leaves, :join_leaves
  end
end
