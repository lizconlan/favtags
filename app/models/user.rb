require 'grackle'

class User < TwitterAuth::GenericUser
  attr_reader :favorites_count
  # Extend and define your user model as you see fit.
  # All of the authentication logic is handled by the 
  # parent TwitterAuth::GenericUser class.
  has_many :tags, :order => 'name'
  has_many :favorites, :order => 'posted DESC'

  def api_calls
    client.account.rate_limit_status?
  end
  
  def delete_favorites
    self.favorites.destroy_all
  end
  
  def update_favcount
    user_data = client.users.show?(:id => twitter_id)
    @favorites_count = user_data.favorites_count
  end

  def load_favorites
    update_favcount
    if self.favorites.count == 0
      load_all_favorites
    else
      load_some_favorites
    end
  end
  
  def search_faves(search_string, page=1, all=false)
    search_string.gsub!("'", "\'")
    search_string.gsub!("%", '\%')
    search_string.gsub!(";", '\;')
    if all
      Favorite.find(:all, :conditions => ["text LIKE ? and user_id=?", "%#{search_string}%", self.id])
    else
      Favorite.search(search_string, self.id, page)
    end
  end
  
  def tag_list_with_count
    faves = Favorite.find_by_sql("select tag.id, tag.name, count(fav.favorite_id) as count from tags tag inner join favorites_tags fav on tag.id = fav.tag_id where tag.user_id = #{self.id} group by fav.tag_id order by tag.name;")
  end
  
  def faved_accounts
    accounts = Favorite.find_by_sql("select twitterer_name as name, count(id) as count from favorites where user_id = #{self.id} group by twitterer_name order by count DESC, twitterer_name")
  end

  def has_tag? tag_name
    tag_names.include?(tag_name)
  end

  def tag_names
    names = tags.collect { |x| x.name }
    names
  end

  def client
    @client ||= set_client(access_token, access_secret)
  end

  private
    def set_client(access_token, access_secret)
      Grackle::Client.new(:auth=>{
        :type => :oauth,
        :consumer_key => TwitterAuth.config['oauth_consumer_key'],
        :consumer_secret => TwitterAuth.config['oauth_consumer_secret'],
        :token => access_token,
        :token_secret => access_secret
      })
    end
  
    def load_some_favorites
      tweets = "starting"
      i = 0
      while i < self.pages_to_load
        i += 1
        
        if i == 1
          tweets = client.favorites?({:count => 20, :include_entities => 1})
        else
          tweets = client.favorites?({:count => 21, :max_id => @max, :include_entities => 1})
        end
        
        if tweets.blank?
          return ""
        else
          @max = tweets.last.id
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
        tweets = client.favorites?({:page => i})
                
        tweets.each do |tweet|
          load_tweet(tweet)
        end
      end
    end
    
    def load_tweet tweet
      unless Favorite.find_by_tweet_id_and_user_id(tweet.id, self.id)
        fave = Favorite.new(
          :user_id => self.id,
          :text => tweet.text,
          :tweet_id => tweet.id,
          :twitterer_name => tweet.user.screen_name,
          :twitterer_real_name => tweet.user.name,
          :twitterer_id => tweet.user.id,
          :twitterer_location => tweet.user.location,
          :twitterer_description => tweet.user.description,
          :twitterer_profile_image_url => tweet.user.profile_image_url,
          :twitterer_url => tweet.user.url,
          :twitterer_protected => tweet.user.protected,
          :twitterer_created_at => tweet.user.created_at,
          :twitterer_utc_offset => tweet.user.utc_offset,
          :twitterer_time_zone => tweet.user.time_zone,
          :twitterer_geo_enabled => tweet.user.geo_enabled,
          :twitterer_verified => tweet.user.verified,
          :twitterer_lang => tweet.user.lang,
          :reply_to_status => tweet.in_reply_to_status_id,
          :reply_to_user => tweet.in_reply_to_screen_name,
          :reply_to_user_id => tweet.in_reply_to_user_id,
          :source => tweet.source,
          :posted => tweet.created_at
        )
        #sort out the geo bit
        if tweet.geo
          fave.geo = tweet.geo.coordinates.join(", ") if tweet.geo.coordinates
          fave.geo_type = tweet.geo.as_json["table"][:type] if tweet.geo.as_json["table"][:type]
        end
        
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
        url_entities = tweet.entities.urls if tweet.entities
        if url_entities
          url_entities.each do |url_hash|
            short_url = url_hash.url
            original_url = url_hash.expanded_url
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
        
        #store
        self.favorites << fave
      end
    end
end
