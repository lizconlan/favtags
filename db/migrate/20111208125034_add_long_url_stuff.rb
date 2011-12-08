class AddLongUrlStuff < ActiveRecord::Migration
  def self.up
    create_table :urls
    add_column :urls, :short, :string
    add_column :urls, :full, :string
    add_column :urls, :favorite_id, :integer
    
    add_index :urls, :short
  end

  def self.down
    drop_table :urls
  end
end
