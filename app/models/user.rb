class User < TwitterAuth::GenericUser
  # Extend and define your user model as you see fit.
  # All of the authentication logic is handled by the 
  # parent TwitterAuth::GenericUser class.
  has_many :tags
  has_many :favourites
  
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
    if self.favourites.empty?
      load_all_favourites
    else
      update_favourites
    end  
  end

  private

    def update_favourites
      last_stored = self.favourites.last.tweet_id
      fav_count = self.favourites_count
      fav_stored = self.favourites.count
      pages = (fav_count.to_f - fav_stored.to_f) / 20
      load_from_twitter(pages, last_stored)
    end

    def load_all_favourites
      fav_count = self.favourites_count
      pages = fav_count.to_f / 20
      load_from_twitter(pages)
    end

    def load_from_twitter pages, last_stored=nil
      if pages.to_i < pages
        pages = pages.to_i + 1
      end
      pages.downto(1) do |i|
        tweets = self.twitter.get("/favorites?page=#{i}").reverse!
        tweets.each do |tweet|
          if last_stored && tweet["id"].to_i > last_stored.to_i
            fave = Favourite.new(
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
            self.favourites <<= fave
          end
        end
      end
    end
end
