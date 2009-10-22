class AddTwittererRealNameToFavourites < ActiveRecord::Migration
  def self.up
    add_column :favourites, :twitterer_real_name, :string
  end

  def self.down
    remove_column :favourites, :twitterer_real_name
  end
end
