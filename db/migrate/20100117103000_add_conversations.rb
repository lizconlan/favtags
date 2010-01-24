class AddConversations < ActiveRecord::Migration
  def self.up
    create_table :conversations, :force => true do |t|
      t.integer :user_id
      t.integer :favourite_id
      t.integer :next_favourite_id
      t.integer :prev_favourite_id
    end
  end

  def self.down
    drop_table :conversations
  end
end
