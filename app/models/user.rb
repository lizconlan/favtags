require 'open-uri'
require 'xmlsimple'

class User < ActiveRecord::Base
  has_many :tags
  has_many :tweets

  def update_favorites
  end
  
  def load_favorites user, page_num
    User.find_or_create_by_id 1
    xml = get_favorites_xml(user, page_num)
    xml["status"].each do |tweet|
      Tweet.create( :user_id => 1, :text => tweet["text"], :twitterer_name => tweet["user"][0]["screen_name"].strip, :twitterer_id => tweet["user"][0]["id"])
      #puts %Q| #{tweet["user"][0]["screen_name"]}: #{tweet["text"]}|
      #puts ""
    end
    return ""
  end

  private
    def get_favorites_xml user, page
      twit_stream = open("http://twitter.com/favorites/#{user}.xml?page=#{page}")
      xml_text = twit_stream.read
      XmlSimple.xml_in(xml_text)
    end
end