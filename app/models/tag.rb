class Tag < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :favorites
  
  def url
    name.gsub("-", "--").gsub(" ", "-")
  end
end