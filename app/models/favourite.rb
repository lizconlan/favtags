class Favourite < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :tags
  
  def html_text
    html = text
    html.scan(/http:\/\/\S*/).each do |match|
      html.gsub!(match, "<a href='#{match}'>#{match}</a>")
    end
    html.scan(/ @\S+/).each do |match|
      html.gsub!(match, " <a href='http://twitter.com/#{match.gsub(" @", "")}'>#{match.strip}</a>")
    end
    html.scan(/^@\S+/).each do |match|
      html.gsub!(match, " <a href='http://twitter.com/#{match.gsub("@", "")}'>#{match.strip}</a>")
    end
    html
  end
end