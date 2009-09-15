class CreateDatabase < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :twitter_id

      t.timestamps
    end
    
    create_table :tags do |t|
      t.integer :user_id
      t.string :name
      t.boolean :public, :default => true
      
      t.timestamps
    end
    
    create_table :tweets do |t|
      t.integer :user_id
      t.string :text, :limit => 140
      t.string :twitterer_name
      t.string :twitterer_id
      t.string :reply_to_status
      t.string :reply_to_user
      t.timestamp :posted
    end
    
    create_table :tags_tweets do |t|
      t.column "tag_id", :integer, :null => false
      t.column "tweet_id",  :integer, :null => false
    end
  end

  def self.down
    drop_table :users
    drop_table :tags
    drop_table :tweets
    drop_table :tags_tweets
  end
end
