class AddGeoTypeToFavorite < ActiveRecord::Migration
  def self.up
    add_column :favorites, :geo_type, :string
  end

  def self.down
    remove_column :favorites, :geo_type
  end
end
