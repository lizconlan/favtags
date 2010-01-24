class AddFieldsToFavourites < ActiveRecord::Migration
  def self.up
    add_column :favourites, :twitterer_location, :string
    add_column :favourites, :twitterer_description, :string
    add_column :favourites, :twitterer_profile_image_url, :string
    add_column :favourites, :twitterer_url, :string
    add_column :favourites, :twitterer_protected, :boolean
    add_column :favourites, :twitterer_followers_count, :integer
    add_column :favourites, :twitterer_profile_background_color, :string
    add_column :favourites, :twitterer_profile_text_color, :string
    add_column :favourites, :twitterer_profile_link_color, :string
    add_column :favourites, :twitterer_profile_sidebar_fill_color, :string
    add_column :favourites, :twitterer_profile_sidebar_border_color, :string
    add_column :favourites, :twitterer_friends_count, :integer
    add_column :favourites, :twitterer_created_at, :datetime
    add_column :favourites, :twitterer_favourites_count, :integer
    add_column :favourites, :twitterer_utc_offset, :integer
    add_column :favourites, :twitterer_time_zone, :string
    add_column :favourites, :twitterer_profile_background_image_url, :string
    add_column :favourites, :twitterer_profile_background_tile, :boolean
    add_column :favourites, :twitterer_notifications, :boolean
    add_column :favourites, :twitterer_geo_enabled, :boolean
    add_column :favourites, :twitterer_verified, :boolean
    add_column :favourites, :twitterer_following, :boolean
    add_column :favourites, :twitterer_statuses_count, :integer
    add_column :favourites, :twitterer_lang, :string
    add_column :favourites, :twitterer_contributors_enabled, :boolean
    add_column :favourites, :truncated, :boolean
    add_column :favourites, :reply_to_user_id, :boolean
    add_column :favourites, :source, :string
  end

  def self.down
    remove_column :favourites, :twitterer_location
    remove_column :favourites, :twitterer_description
    remove_column :favourites, :twitterer_profile_image_url
    remove_column :favourites, :twitterer_url
    remove_column :favourites, :twitterer_protected
    remove_column :favourites, :twitterer_followers_count
    remove_column :favourites, :twitterer_profile_background_color
    remove_column :favourites, :twitterer_profile_text_color
    remove_column :favourites, :twitterer_profile_link_color
    remove_column :favourites, :twitterer_profile_sidebar_fill_color
    remove_column :favourites, :twitterer_profile_sidebar_border_color
    remove_column :favourites, :twitterer_friends_count
    remove_column :favourites, :twitterer_created_at
    remove_column :favourites, :twitterer_favourites_count
    remove_column :favourites, :twitterer_utc_offset
    remove_column :favourites, :twitterer_time_zone
    remove_column :favourites, :twitterer_profile_background_image_url
    remove_column :favourites, :twitterer_profile_background_tile
    remove_column :favourites, :twitterer_notifications
    remove_column :favourites, :twitterer_geo_enabled
    remove_column :favourites, :twitterer_verified
    remove_column :favourites, :twitterer_following
    remove_column :favourites, :twitterer_statuses_count
    remove_column :favourites, :twitterer_lang
    remove_column :favourites, :twitterer_contributors_enabled
    remove_column :favourites, :truncated
    remove_column :favourites, :reply_to_user_id
    remove_column :favourites, :source
  end
end
