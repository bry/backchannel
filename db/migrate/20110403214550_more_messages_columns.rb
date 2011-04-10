class MoreMessagesColumns < ActiveRecord::Migration
  def self.up
	add_column :messages, :user_id_from, :integer
	add_column :messages, :user_id_to, :integer
	
  end

  def self.down
 	remove_column :messages, user_id_from
	remove_column :messages, user_id_to

  end
end
