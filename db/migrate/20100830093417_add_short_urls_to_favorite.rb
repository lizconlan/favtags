class AddShortUrlsToFavorite < ActiveRecord::Migration
  def self.up
    add_column :favorites, :short_urls, :string
  end

  def self.down
    remove_column :favorites, :short_urls
  end
end
