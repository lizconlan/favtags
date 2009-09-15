class CreateDatabase < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :twitter_id

      t.timestamps
    end
    
    create_table :tags do |t|
      t.string :name
      t.boolean :public, :default => true
      
      t.timestamps
    end
    
    create_table :tweets do |t|
      t.string :body, :limit => 140
      t.string :status
      t.string :user_id
      t.string :posted_from
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
