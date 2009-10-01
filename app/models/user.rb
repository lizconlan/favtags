require 'open-uri'
require 'xmlsimple'

class User < TwitterAuth::GenericUser
  # Extend and define your user model as you see fit.
  # All of the authentication logic is handled by the 
  # parent TwitterAuth::GenericUser class.
  has_many :tags
  has_many :tweets
  
  def update_favorites
  end

  def load_favorites twitter_user, page_num
    User.find_or_create_by_id 1
    xml = get_favorites_xml(twitter_user, page_num)
    xml["status"].each do |tweet|
      Tweet.create( 
        :user_id => 1, 
        :text => tweet["text"].to_s, 
        :twitterer_name => tweet["user"][0]["screen_name"].to_s.strip, 
        :twitterer_id => tweet["user"][0]["id"].to_s,
        :reply_to_status => tweet["user"][0]["in_reply_to_status_id"].to_s,
        :reply_to_user => tweet["user"][0]["in_reply_to_screen_name"].to_s,
        :posted => tweet["created_at"].to_s)
    end
  end

  private
    def get_favorites_xml user, page
      twit_stream = open("http://twitter.com/favorites/#{user}.xml?page=#{page}")
      xml_text = twit_stream.read
      XmlSimple.xml_in(xml_text)
    end
end
