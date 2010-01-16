class User < TwitterAuth::GenericUser
  # Extend and define your user model as you see fit.
  # All of the authentication logic is handled by the 
  # parent TwitterAuth::GenericUser class.
  has_many :tags
  has_many :favourites, :order => 'posted DESC'
  
  def delete_favorites
    self.favourites.destroy_all
  end
  
  def update_favcount
    user_data = self.twitter.get("/users/show/#{self.twitter_id}")
    fav_count = user_data["favourites_count"]
    favourites_count = fav_count
    save!
  end

  def load_favourites
    update_favcount
    load_all_favourites
  end
  
  def faved_tweeple
    grouped_faves = self.favourites.group_by { |x| x.twitterer_name }
    tweeple = grouped_faves.keys
    tweeple.sort { |a,b| a.downcase <=> b.downcase }
  end

  private

    def load_all_favourites
      tweets = "starting"
      i = 0
      while !tweets.blank?
        i += 1
        tweets = self.twitter.get("/favorites?page=#{i}")
        tweets.each do |tweet|
          unless Favourite.find_by_tweet_id_and_user_id(tweet["id"], self.id)
            fave = Favourite.new(
              :user_id => self.id,
              :text => tweet["text"],
              :tweet_id => tweet["id"],
              :twitterer_name => tweet["user"]["screen_name"],
              :twitterer_real_name => tweet["user"]["name"],
              :twitterer_id => tweet["user"]["id"],
              :reply_to_status => tweet["in_reply_to_status_id"],
              :reply_to_user => tweet["in_reply_to_screen_name"],
              :posted => tweet["created_at"],
              :geo => tweet["geo"]
            )
            self.favourites <<= fave
          end
        end
      end
    end
end
