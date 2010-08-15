class Favorite < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 10
    
  belongs_to :user
  has_and_belongs_to_many :tags
  
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
  
  def html_text
    html = text
    html.scan(/https*:\/\/\S*/).each do |match|
      html.gsub!(match, "<a href=\"#{match}\">#{match}</a>")
    end
    html.scan(/(?:\W|,)(@[a-zA-Z0-9_]+)/).each do |match|
      html.gsub!(match.to_s, %Q|<a href="http://twitter.com/#{match.first.gsub("@", "")}">#{match.to_s.strip}</a>|)
    end
    html.scan(/^(@[a-zA-Z0-9_]+)/).each do |match|
      html.gsub!(match.to_s, "<a href=\"http://twitter.com/#{match.first.gsub("@", "")}\">#{match.to_s.strip}</a>")
    end
    html.scan(/(?:\ |!|\(|^)(#[a-zA-Z0-9_]+)/).each do |match|
      html.gsub!(match.to_s, "<a href=\"http://search.twitter.com/search?q=#{match.first.to_s.gsub('#','%23')}\">#{match.first.to_s.strip}</a>")
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
    self.user.twitter.post("/favorites/destroy/#{self.tweet_id}")
    self.destroy
  end
end