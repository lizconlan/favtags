require 'json'
require 'rest_client'
require 'lib/url_lengthener'

class Favorite < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 10
    
  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :urls
  
  validates_uniqueness_of :tweet_id, :scope => :user_id, :on	=> :create,
    :message => "already loaded"
  
  class << self
    def find_all_by_tag_name_and_user_id tag_name, user_id
      tag = Tag.find_by_name_and_user_id(tag_name, user_id)
      if tag
        tag.favorites
      else
        []
      end
    end
  end
  
  def shortened_urls
    create_short_urls if short_urls.nil? or short_urls.strip == ""
    short_urls.split(",")
  end
  
  def html_text
    html = text
    counter = 0
    lengthened = []
    full_links = []
    urls.each do |url|
      lengthened << url.short
      full_links << url.full
      html.gsub!(url.short, display_url(url.short, url.full))
    end
    html.scan(/(http(?:[^\s\"\”\<])*)/).each do |match|
      match = match.to_s
      if match =~ /(.*)\.$/
        match = $1
      end
      
      unless lengthened.include?(match) or full_links.include?(match) or match.include?("&hellip;")
        expanded = UrlLengthener.expand_url(match)
        if expanded == match
          html.gsub!(match, display_url(match, expanded))
        else
          new_url = Url.new()
          new_url.short = match
          new_url.full = UrlLengthener.expand_url(match)
          urls << new_url
          self.save
          html.gsub!(match, display_url(match, new_url.full))
        end
      end
    end
    
    html.scan(/(?:\W|,|^)(@[a-zA-Z0-9_]+)/).each do |match|
      html.gsub!(match.to_s, %Q|<a href="http://twitter.com/#{match.first.gsub("@", "")}">#{match.to_s.strip}</a>|)
    end
    hashtags.each do |match|
      html.gsub!("\##{match}".to_s, "<a href=\"http://search.twitter.com/search?q=%23#{match.to_s}\">\##{match.to_s.strip}</a>")
    end
    html.gsub!("\n", "<br />")
    html.gsub!(/\<\s*script/, "&gt;script")
    html.gsub!("</\s*script", "&gt;/script")
    html.to_s
  end
  
  def hashtags
    potentials = text.scan(/(?:\s|^)#([a-zA-Z0-9\-]{2,})/).flatten
    potentials.delete_if { |x| x =~ /^[0-9]*$/}
  end
  
  def inline_urls
    text.scan(/(?:\s|^)(https?:\/\/[a-zA-Z0-9\.\/\&\#\?\=\-\_\%\+\:]*)/i).flatten
  end
  
  def create_short_urls
    conf = YAML.load(File.read('config/bitly.yml'))
    api_key = conf[:api_key]
    
    shortened = []
    inline_urls.each do |url|
      if url.length > 30
        api_url = "http://api.bit.ly/v3/shorten?login=favtagger&apiKey=#{api_key}&longUrl=#{url}&format=json"
        data = RestClient.get api_url
        result = JSON.parse(data.body)
        if result["status_code"] == 200
          short_url = result["data"]["url"]
          shortened << short_url
        else
          shortened << ""
        end
      else
        shortened << ""
      end
    end
    self.short_urls = shortened.join(",")
    self.save
  end
  
  def has_tag? tag_name
    tag_names.include?(tag_name)
  end
  
  def tag_names
    names = tags.collect { |x| x.name }
    names
  end
  
  def tag tag_name, user_id
    unless has_tag?(tag_name.strip)
      new_tag = Tag.find_or_create_by_name_and_user_id(tag_name, user_id)
      self.tags << new_tag
    end
  end
  
  def utc_offset
    unless twitterer_utc_offset
      "+0000"
    else
      offset = twitterer_utc_offset / 36
      if offset < 0
        offset = offset * -1
        offset = offset.to_s.rjust(4, "0")
        "-#{offset}"
      else
        offset = offset.to_s.rjust(4, "0")
        "+#{offset}"
      end
    end
  end
  
  def detag tag_name
    if has_tag?(tag_name)
      tag = tags.find_by_name(tag_name)
      self.tags.delete(tag)
    end
  end
  
  def delete
    self.tags.each do |tag|
      self.tags.delete(tag)
    end
    begin
      user.client(user.access_token, user.access_secret).favorite_destroy(self.tweet_id)
    rescue Exception => exc
      #do nothing
    end
    self.destroy
  end
  
  def display_url(link, full_url)
    full_url = full_url.gsub(" ", "%20").gsub('"', "%22")
    url_parts = URI.parse(full_url)
    if url_parts.query
      qs = "?..."
    else
      qs = ""
    end
    %Q|<a title="#{full_url}" href="#{link}">#{url_parts.host}#{url_parts.path}#{qs}</a>|
  end
end