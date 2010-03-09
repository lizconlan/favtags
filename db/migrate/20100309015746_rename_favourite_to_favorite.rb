class RenameFavouriteToFavorite < ActiveRecord::Migration
  def self.up
    rename_table :favourites, :favorites
    rename_column :favorites, :twitterer_favourites_count, :twitterer_favorites_count
    rename_column :conversations, :favourite_id, :favorite_id
    rename_column :conversations, :next_favourite_id, :next_favorite_id
    rename_column :conversations, :prev_favourite_id, :prev_favorite_id
    rename_table :favourites_tags, :favorites_tags
    rename_column :favorites_tags, :favourite_id, :favorite_id
    rename_column :users, :favourites_count, :favorites_count
  end

  def self.down
    rename_column :users, :favorites_count, :favourites_count
    rename_column :favorites_tags, :favorite_id, :favourite_id
    rename_table :favorites_tags, :favourites_tags
    rename_column :favorites, :twitterer_favorites_count, :twitterer_favourites_count
    rename_column :conversations, :favorite_id, :favourite_id
    rename_column :conversations, :next_favorite_id, :next_favourite_id
    rename_column :conversations, :prev_favorite_id, :prev_favourite_id
    rename_table :favorites, :favourites
  end
end
