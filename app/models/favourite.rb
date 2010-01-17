class Favourite < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 20
    
  belongs_to :user
  has_and_belongs_to_many :tags
  
  def html_text
    html = text
    html.scan(/http:\/\/\S*/).each do |match|
      html.gsub!(match, "<a href='#{match}'>#{match}</a>")
    end
    html.scan(/(?:\W|,)(@[a-zA-Z0-9_]+)/).each do |match|
      html.gsub!(match.to_s, %Q| <a href="http://twitter.com/#{match.first.gsub("@", "")}">#{match.to_s.strip}</a>|)
    end
    html.scan(/^(@[a-zA-Z0-9_]+)/).each do |match|
      html.gsub!(match.to_s, " <a href='http://twitter.com/#{match.first.gsub("@", "")}'>#{match.to_s.strip}</a>")
    end
    html.scan(/(?:\ |\()(#[a-zA-Z0-9_]+)/).each do |match|
      html.gsub!(match.to_s, " <a href='http://search.twitter.com/search?q=#{match.first.to_s.gsub('#','%23')}'>#{match.first.to_s.strip}</a>")
    end
    html.to_s
  end
end