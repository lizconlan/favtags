class AddGeoAndTweetIdToTweets < ActiveRecord::Migration
  def self.up
    add_column :tweets, :geo, :string
    add_column :tweets, :tweet_id, :string
  end

  def self.down
    remove_column :tweets, :geo
    remove_column :tweets, :tweet_id
  end
end
