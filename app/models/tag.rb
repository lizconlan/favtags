class Tag < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :favorites
  
  def url
    name.squeeze(" ").gsub("-", "--").gsub(" ", "-")
  end
  
  def delete
    self.favorites.each do |fave|
      fave.detag(self)
    end
    self.destroy
  end
end