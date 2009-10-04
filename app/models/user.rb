class User < TwitterAuth::GenericUser
  # Extend and define your user model as you see fit.
  # All of the authentication logic is handled by the 
  # parent TwitterAuth::GenericUser class.
  has_many :tags
  has_many :tweets
  
  def update_favorites
  end

  def load_favorites page_num=1
    test = self.twitter.get("/users/show/#{self.twitter_id}")
    fav_count = test["favourites_count"]
    tweets = self.twitter.get('/favorites')
    tweets.each do |tweet|
      Tweet.create(
        :user_id => self.id,
        :text => tweet["text"],
        :tweet_id => tweet["id"],
        :twitterer_name => tweet["user"]["screen_name"],
        :twitterer_id => tweet["user"]["id"],
        :reply_to_status => tweet["in_reply_to_user_id"],
        :reply_to_user => tweet["in_reply_to_screen_name"],
        :posted => tweet["created_at"],
        :geo => tweet["geo"]
      )
    end
  end

  private

end
