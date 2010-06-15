class DropUnwantedFields < ActiveRecord::Migration
  def self.up
    remove_column :favorites, :twitterer_followers_count
    remove_column :favorites, :twitterer_profile_background_color
    remove_column :favorites, :twitterer_profile_text_color
    remove_column :favorites, :twitterer_profile_link_color
    remove_column :favorites, :twitterer_profile_sidebar_fill_color
    remove_column :favorites, :twitterer_profile_sidebar_border_color
    remove_column :favorites, :twitterer_friends_count
    remove_column :favorites, :twitterer_favorites_count
    remove_column :favorites, :twitterer_profile_background_image_url
    remove_column :favorites, :twitterer_profile_background_tile
    remove_column :favorites, :twitterer_notifications
    remove_column :favorites, :twitterer_statuses_count
  end

  def self.down
    add_column :favorites, :twitterer_followers_count, :integer
    add_column :favorites, :twitterer_profile_background_color, :string
    add_column :favorites, :twitterer_profile_text_color, :string
    add_column :favorites, :twitterer_profile_link_color, :string
    add_column :favorites, :twitterer_profile_sidebar_fill_color, :string
    add_column :favorites, :twitterer_profile_sidebar_border_color, :string
    add_column :favorites, :twitterer_friends_count, :integer
    add_column :favorites, :twitterer_favorites_count, :integer
    add_column :favorites, :twitterer_profile_background_image_url, :string
    add_column :favorites, :twitterer_profile_background_tile, :boolean
    add_column :favorites, :twitterer_notifications, :boolean
    add_column :favorites, :twitterer_statuses_count, :integer
  end
end
