class DropTweetsTags < ActiveRecord::Migration
  def self.up
    drop_table :tags_tweets
  end

  def self.down
    create_table :tags_tweets do |t|
      t.column "tag_id", :integer, :null => false
      t.column "tweet_id",  :integer, :null => false
    end
  end
end
