class User < TwitterAuth::GenericUser
  # Extend and define your user model as you see fit.
  # All of the authentication logic is handled by the 
  # parent TwitterAuth::GenericUser class.
  has_many :tags, :order => 'name'
  has_many :favorites, :order => 'posted DESC'

  def api_calls
    response = self.twitter.get("/account/rate_limit_status.json")
    [response["remaining_hits"], response["reset_time"]]
  end
  
  def delete_favorites
    self.favorites.destroy_all
  end
  
  def update_favcount
    user_data = self.twitter.get("/users/show/#{self.twitter_id}")
    fav_count = user_data["favorites_count"]
    self.favorites_count = fav_count
    save!
  end

  def load_favorites
    update_favcount
    if self.favorites.count == 0
      load_all_favorites
    else
      load_some_favorites
    end
  end
  
  def faved_accounts
    grouped_faves = self.favorites.group_by { |x| x.twitterer_name }
    accounts = []
    grouped_faves.keys.each do |account|
      accounts << {:name => account, :count => grouped_faves[account].count }
    end
    accounts.sort { |a,b| [b[:count], a[:name]] <=> [a[:count], b[:name]] }
  end

  def has_tag? tag_name
    tag_names.include?(tag_name)
  end

  def tag_names
    names = tags.collect { |x| x.name }
    names
  end

  private

    def load_some_favorites(pages=4)
      tweets = "starting"
      i = 0
      while i < pages
        i += 1
        tweets = self.twitter.get("/favorites.json?page=#{i}")
        
        if tweets.blank?
          return ""
        end
                
        tweets.each do |tweet|
          load_tweet(tweet)
        end
      end
    end

    def load_all_favorites
      tweets = "starting"
      i = 0
      while !tweets.blank?
        i += 1
        tweets = self.twitter.get("/favorites.json?page=#{i}")
                
        tweets.each do |tweet|
          load_tweet(tweet)
        end
      end
    end
    
    def load_tweet tweet
      unless Favorite.find_by_tweet_id_and_user_id(tweet["id"], self.id)
        fave = Favorite.new(
          :user_id => self.id,
          :text => tweet["text"],
          :tweet_id => tweet["id"],
          :twitterer_name => tweet["user"]["screen_name"],
          :twitterer_real_name => tweet["user"]["name"],
          :twitterer_id => tweet["user"]["id"],
          :twitterer_location => tweet["user"]["location"],
          :twitterer_description => tweet["user"]["description"],
          :twitterer_profile_image_url => tweet["user"]["profile_image_url"],
          :twitterer_url => tweet["user"]["url"],
          :twitterer_protected => tweet["user"]["protected"],
          :twitterer_created_at => tweet["user"]["created_at"],
          :twitterer_utc_offset => tweet["user"]["utc_offset"],
          :twitterer_time_zone => tweet["user"]["time_zone"],
          :twitterer_geo_enabled => tweet["user"]["geo_enabled"],
          :twitterer_verified => tweet["user"]["verified"],
          :twitterer_lang => tweet["user"]["lang"],
          :reply_to_status => tweet["in_reply_to_status_id"],
          :reply_to_user => tweet["in_reply_to_screen_name"],
          :reply_to_user_id => tweet["in_reply_to_user_id"],
          :source => tweet["source"],
          :posted => tweet["created_at"]
        )
        fave.geo = tweet["geo"]["georss:point"] if tweet["geo"] && tweet["geo"]["georss:point"]
        begin
          self.favorites <<= fave
        rescue Exception => exc
          unless exc.message == "already loaded"
            raise exc.message
          end
        end
      end
    end
end
