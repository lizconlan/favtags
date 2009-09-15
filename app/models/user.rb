class User < ActiveRecord::Base
  has_many :tags
  has_many :tweets
end

def update_favorites
end