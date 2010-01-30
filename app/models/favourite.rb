class Favourite < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 20
    
  belongs_to :user
  has_and_belongs_to_many :tags
  
  validates_uniqueness_of :tweet_id, :scope => :user_id, :on	=> :create,
    :message => "already loaded"
  
  def html_text
    html = text
    html.scan(/https*:\/\/\S*/).each do |match|
      html.gsub!(match, "<a href='#{match}'>#{match}</a>")
    end
    html.scan(/(?:\W|,)(@[a-zA-Z0-9_]+)/).each do |match|
      html.gsub!(match.to_s, %Q| <a href="http://twitter.com/#{match.first.gsub("@", "")}">#{match.to_s.strip}</a>|)
    end
    html.scan(/^(@[a-zA-Z0-9_]+)/).each do |match|
      html.gsub!(match.to_s, " <a href='http://twitter.com/#{match.first.gsub("@", "")}'>#{match.to_s.strip}</a>")
    end
    html.scan(/(?:\ |!|\(|^)(#[a-zA-Z0-9_]+)/).each do |match|
      html.gsub!(match.to_s, " <a href='http://search.twitter.com/search?q=#{match.first.to_s.gsub('#','%23')}'>#{match.first.to_s.strip}</a>")
    end
    html.gsub!("\n", "<br />")
    html.to_s
  end
  
  def has_tag? tag_name
    tag_names.include?(tag_name)
  end
  
  def tag_names
    names = tags.collect { |x| x.name }
    names
  end
  
  def tag tag_name, user_id
    unless has_tag?(tag_name)
      new_tag = Tag.find_or_create_by_name_and_user_id(tag_name, user_id)
      self.tags<< new_tag
    end
  end
  
  def detag tag_name
    if has_tag?(tag_name)
      tag = tags.find_by_name(tag_name)
      self.tags.delete(tag)
      if tag.favourites.count == 0
        tag.delete
      end
    end
  end
end