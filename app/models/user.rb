require 'twitter'

class User < TwitterAuth::GenericUser
  # Extend and define your user model as you see fit.
  # All of the authentication logic is handled by the 
  # parent TwitterAuth::GenericUser class.
  has_many :tags, :order => 'name'
  has_many :favorites, :order => 'posted DESC'

  def api_calls
    client(access_token, access_secret).rate_limit_status
  end
  
  def delete_favorites
    self.favorites.destroy_all
  end
  
  def update_favcount
    user_data = Twitter.get("/users/show/#{self.twitter_id}")
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
  
    def client(access_token, access_secret)
      Twitter.configure do |config|
        config.consumer_key = TwitterAuth.config['oauth_consumer_key']
        config.consumer_secret = TwitterAuth.config['oauth_consumer_secret']
        config.oauth_token = access_token
        config.oauth_token_secret = access_secret
      end
      @client ||= Twitter::Client.new
    end

    def load_some_favorites
      tweets = "starting"
      i = 0
      while i < self.pages_to_load
        i += 1
        
        tweets = client(access_token, access_secret).favorites(login, {:page => i, :include_entities => 1})
        
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
        tweets = client(access_token, access_secret).favorites(login, {:page => i})
                
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
        #sort out the geo bit
        fave.geo = tweet["geo"]["coordinates"].join(", ") if tweet["geo"] && tweet["geo"]["coordinates"]
        fave.geo_type = tweet["geo"]["type"] if tweet["geo"] && tweet["geo"]["type"]
        
        #process the autotags (if requested)
        if self.autocreate_tags
          fave.hashtags.each do |hashtag|
            unless self.has_tag?(hashtag)
              if hashtag.length > 2
                fave.tag(hashtag, self.id)
              end
            end
          end
        end
        
        #stash the decrapped the urls
        url_entities = tweet["entities"]["urls"] if tweet["entities"] 
        if url_entities
          url_entities.each do |url_hash|
            short_url = url_hash["url"]
            original_url = url_hash["expanded_url"]
            #begin
              expanded_url = UrlLengthener.expand_url(short_url)
            #rescue
            #  expanded_url = original_url
            #end
            new_url = Url.find_or_create_by_short_and_favorite_id(short_url, fave.id)
            new_url.short = short_url
            new_url.full = expanded_url
            if fave.id
              new_url.favorite_id = fave.id
              new_url.save
            else
              fave.urls << new_url
            end
          end
        end
        
        #store unless duplicate
        ids = self.favorites.collect { |x| x.tweet_id }
        unless ids.include?(fave.tweet_id)
          self.favorites << fave
        end
      end
    end
end
