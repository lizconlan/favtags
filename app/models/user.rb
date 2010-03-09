class User < TwitterAuth::GenericUser
  # Extend and define your user model as you see fit.
  # All of the authentication logic is handled by the 
  # parent TwitterAuth::GenericUser class.
  has_many :tags, :order => 'name'
  has_many :favorites, :order => 'posted DESC'
  
  def delete_favorites
    self.favorites.destroy_all
  end
  
  def update_favcount
    user_data = self.twitter.get("/users/show/#{self.twitter_id}")
    fav_count = user_data["favorites_count"]
    favorites_count = fav_count
    save!
  end

  def load_favorites
    update_favcount
    load_all_favorites
  end
  
  def faved_tweeple
    grouped_faves = self.favorites.group_by { |x| x.twitterer_name }
    tweeple = grouped_faves.keys
    tweeple.sort { |a,b| a.downcase <=> b.downcase }
  end

  def has_tag? tag_name
    !tags.find_by_name(tag_name).nil
  end

  def tag_names
    names = tags.collect { |x| x.name }
    names
  end

  private

    def load_all_favorites
      tweets = "starting"
      i = 0
      while !tweets.blank?
        i += 1
        tweets = self.twitter.get("/favorites?page=#{i}")
        tweets.each do |tweet|
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
              :twitterer_followers_count => tweet["user"]["followers_count"],
              :twitterer_profile_background_color => tweet["user"]["profile_background_color"],
              :twitterer_profile_text_color => tweet["user"]["profile_text_color"],
              :twitterer_profile_link_color => tweet["user"]["profile_link_color"],
              :twitterer_profile_sidebar_fill_color => tweet["user"]["profile_sidebar_fill_color"],
              :twitterer_profile_sidebar_border_color => tweet["user"]["profile_sidebar_border_color"],
              :twitterer_friends_count => tweet["user"]["friends_count"],
              :twitterer_created_at => tweet["user"]["created_at"],
              :twitterer_favorites_count => tweet["user"]["favourites_count"],
              :twitterer_utc_offset => tweet["user"]["utc_offset"],
              :twitterer_time_zone => tweet["user"]["time_zone"],
              :twitterer_profile_background_image_url => tweet["user"]["profile_background_image_url"],
              :twitterer_profile_background_tile => tweet["user"]["profile_background_tile"],
              :twitterer_notifications => tweet["user"]["notifications"],
              :twitterer_geo_enabled => tweet["user"]["geo_enabled"],
              :twitterer_verified => tweet["user"]["verified"],
              :twitterer_following => tweet["user"]["following"],
              :twitterer_statuses_count => tweet["user"]["statuses_count"],
              :twitterer_lang => tweet["user"]["lang"],
              :twitterer_contributors_enabled => tweet["user"]["contributors_enabled"],
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
    end
end
