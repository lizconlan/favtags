# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090915152441) do

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.boolean  "public",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags_tweets", :force => true do |t|
    t.integer "tag_id",   :null => false
    t.integer "tweet_id", :null => false
  end

  create_table "tweets", :force => true do |t|
    t.string   "body",            :limit => 140
    t.string   "status"
    t.string   "user_id"
    t.string   "posted_from"
    t.string   "reply_to_status"
    t.string   "reply_to_user"
    t.datetime "posted"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "twitter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
