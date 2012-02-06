require 'json'
require 'iconv'
require 'rest_client'
require 'lib/url_lengthener'
require 'htmlentities'

class Favorite < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 10
    
  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :urls
  
  validates_uniqueness_of :tweet_id, :scope => :user_id, :on	=> :create,
    :message => "already loaded"
  
  class << self
    def find_all_by_tag_name_and_user_id(tag_name, user_id, page=1, all=false)
      if all
        tag = Tag.find_by_name_and_user_id(tag_name, user_id)
        tag.favorites
      else
        paginate :per_page => self.per_page, :page => page,
                 :conditions => ['favorites.user_id = ? and tags.name = ?', user_id, "#{tag_name}"],
                 :joins => "inner join favorites_tags on favorites.id = favorites_tags.favorite_id inner join tags on favorites_tags.tag_id = tags.id",
                 :order => "posted DESC"
      end
    end
    
    def search(search, user, page=1)
      paginate :per_page => self.per_page, :page => page,
               :conditions => ['text like ? and user_id = ?', "%#{search}%", user],
               :order => "posted DESC"
    end
  end
  
  def shortened_urls
    create_short_urls if short_urls.nil? or short_urls.strip == ""
    short_urls.split(",")
  end
  
  def html_text
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    html = ic.iconv(text + ' ')[0..-2]
    
    html.gsub!(/[”“”]/, '"')
    
    counter = 0
    lengthened = []
    full_links = []
    
    #stored short links
    urls.each do |url|
      lengthened << url.short
      full = url.full.gsub(" ", "%20")
      full_links << full
      html.gsub!(url.short, display_url(url.short, full))
    end
    
    
    # if html =~ (/t\.co\/Ml02zcZL/)
    #   raise html.inspect
    # end
    
    #new short links
    html.scan(/(http(?:[^\s\"\”\<])*)/).each do |match|
      match = match.to_s      
      if match =~ /(.*)\.$/
        match = $1
      end
      
      p match[-1,1]
      
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
    
    #account names
    html.scan(/(?:\W|,|^)(@[a-zA-Z0-9_]+)/).each do |match|
      html.gsub!(match.to_s, %Q|<a href="http://twitter.com/#{match.first.gsub("@", "")}">#{match.to_s.strip}</a>|)
    end
    
    #hashtags
    hashtags.each do |match|
      html.gsub!("\##{match} ".to_s, "<a href=\"http://search.twitter.com/search?q=%23#{match.to_s}\">\##{match.to_s.strip}</a> ")
      html.gsub!(/\##{match.to_s}$/, "<a href=\"http://search.twitter.com/search?q=%23#{match.to_s}\">\##{match.to_s.strip}</a>")
    end
    
    #html encode newlines
    html.gsub!("\n", "<br />")
    
    #html encode script tags
    html.gsub!(/\<\s*script/, "&gt;script")
    html.gsub!("</\s*script", "&gt;/script")
    html.to_s
  end
  
  def hashtags
    potentials = text.scan(/(?:\s|^)#([a-zA-Z0-9\-]{2,})/).flatten
    potentials = potentials.delete_if { |x| x =~ /^[0-9]*$/}
    potentials.delete_if { |x| !(" #{text} ".include?(" ##{x} "))}
  end
  
  def inline_urls
    text.scan(/(?:\s|^)(https?:\/\/[a-zA-Z0-9\.\/\&\#\?\=\-\_\%\+\:]*)/i).flatten
  end
  
  def create_short_urls
    conf = YAML.load(File.read('config/bitly.yml'))
    api_key = conf[:api_key]
    
    shortened = []
    inline_urls.each do |url|
      if url and url.length > 30
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
    while full_url[-1,1] == '#'
      full_url = full_url[0..full_url.length-2]
    end
    begin
      url_parts = URI.parse(full_url)
      if url_parts.query
        qs = "?..."
      else
        qs = ""
      end
      return %Q|<a title="#{full_url}" href="#{link}">#{url_parts.host.gsub("www.","")}#{url_parts.path}#{qs}</a>|
    rescue
      return %Q|<a title="#{full_url}" href="#{link}">#{full_url}</a>|
    end
  end
end