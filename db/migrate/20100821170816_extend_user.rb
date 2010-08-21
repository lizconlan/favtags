class ExtendUser < ActiveRecord::Migration
  def self.up
    add_column :users, :pages_to_load, :integer, :default => 4
    add_column :users, :autocreate_tags, :boolean, :default => true
  end

  def self.down
    remove_column :users, :pages_to_load
    remove_column :users, :autocreate_tags
  end
end
