class RenameTweetsAsFavourites < ActiveRecord::Migration
  def self.up
    rename_table :tweets, :favourites
  end

  def self.down
    rename_table :favourites, :tweets
  end
end
