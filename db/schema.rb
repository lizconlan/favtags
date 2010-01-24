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

ActiveRecord::Schema.define(:version => 20100124170220) do

  create_table "conversations", :force => true do |t|
    t.integer "user_id"
    t.integer "favourite_id"
    t.integer "next_favourite_id"
    t.integer "prev_favourite_id"
  end

  create_table "favourites", :force => true do |t|
    t.integer  "user_id"
    t.string   "text",                                   :limit => 140
    t.string   "twitterer_name"
    t.string   "twitterer_id"
    t.string   "reply_to_status"
    t.string   "reply_to_user"
    t.datetime "posted"
    t.string   "geo"
    t.string   "tweet_id"
    t.string   "twitterer_real_name"
    t.string   "twitterer_location"
    t.string   "twitterer_description"
    t.string   "twitterer_profile_image_url"
    t.string   "twitterer_url"
    t.boolean  "twitterer_protected"
    t.integer  "twitterer_followers_count"
    t.string   "twitterer_profile_background_color"
    t.string   "twitterer_profile_text_color"
    t.string   "twitterer_profile_link_color"
    t.string   "twitterer_profile_sidebar_fill_color"
    t.string   "twitterer_profile_sidebar_border_color"
    t.integer  "twitterer_friends_count"
    t.datetime "twitterer_created_at"
    t.integer  "twitterer_favourites_count"
    t.integer  "twitterer_utc_offset"
    t.string   "twitterer_time_zone"
    t.string   "twitterer_profile_background_image_url"
    t.boolean  "twitterer_profile_background_tile"
    t.boolean  "twitterer_notifications"
    t.boolean  "twitterer_geo_enabled"
    t.boolean  "twitterer_verified"
    t.boolean  "twitterer_following"
    t.integer  "twitterer_statuses_count"
    t.string   "twitterer_lang"
    t.boolean  "twitterer_contributors_enabled"
    t.boolean  "truncated"
    t.boolean  "reply_to_user_id"
    t.string   "source"
  end

  create_table "favourites_tags", :id => false, :force => true do |t|
    t.integer "tag_id",       :null => false
    t.integer "favourite_id", :null => false
  end

  create_table "jobs", :force => true do |t|
    t.string   "worker_class"
    t.string   "worker_method"
    t.text     "args"
    t.text     "result"
    t.integer  "priority"
    t.integer  "progress"
    t.string   "state"
    t.integer  "lock_version",  :default => 0
    t.datetime "start_at"
    t.datetime "started_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "jobs", ["priority"], :name => "index_jobs_on_priority"
  add_index "jobs", ["start_at"], :name => "index_jobs_on_start_at"
  add_index "jobs", ["state"], :name => "index_jobs_on_state"

  create_table "tags", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.boolean  "public",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "twitter_id"
    t.string   "login"
    t.string   "access_token"
    t.string   "access_secret"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "location"
    t.string   "description"
    t.string   "profile_image_url"
    t.string   "url"
    t.boolean  "protected"
    t.string   "profile_background_color"
    t.string   "profile_sidebar_fill_color"
    t.string   "profile_link_color"
    t.string   "profile_sidebar_border_color"
    t.string   "profile_text_color"
    t.string   "profile_background_image_url"
    t.boolean  "profile_background_tiled"
    t.integer  "friends_count"
    t.integer  "statuses_count"
    t.integer  "followers_count"
    t.integer  "favourites_count"
    t.integer  "utc_offset"
    t.string   "time_zone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "job_id"
  end

end
