class User < TwitterAuth::GenericUser
  # Extend and define your user model as you see fit.
  # All of the authentication logic is handled by the 
  # parent TwitterAuth::GenericUser class.
  has_many :tags
  has_many :favourites
  
  def delete_favorites
    self.tweets.destroy_all
  end
  
  def update_favorites
    unless self.favourites
      load_favourites
    else
      #do something a bit cleverer
    end
  end
  
  def update_favcount
    user_data = self.twitter.get("/users/show/#{self.twitter_id}")
    fav_count = user_data["favourites_count"]
    favourites_count = fav_count
    save!
  end

  def load_favorites
    update_favcount
    fav_count = self.favourites_count
    pages = fav_count.to_f / 20
    if pages.to_i < pages
      pages = pages.to_i + 1
    end
    pages.downto(1) do |i|
      tweets = self.twitter.get("/favorites?page=#{i}").reverse!
      tweets.each do |tweet|
        Favourite.create(
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
  end

  private

end
