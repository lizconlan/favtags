require 'active_record'
require 'models/user.rb'
require 'models/favorite.rb'

class FavoritesLoader
      
  def load_user_favorites user_id
    current_user = User.find_by_id(user_id.to_i)
    current_user.load_favorites
  end
end