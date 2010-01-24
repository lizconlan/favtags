class CreateFavouritesTags < ActiveRecord::Migration
  def self.up
    create_table :favourites_tags, :id => false do |t|
      t.column "tag_id", :integer, :null => false
      t.column "favourite_id",  :integer, :null => false
    end
  end

  def self.down
    drop_table :favourites_tags
  end
end
