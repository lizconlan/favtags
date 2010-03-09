require 'active_record'
require 'models/user.rb'
require 'models/favorite.rb'

class FavoritesLoader
  
  #include BackgroundFu::WorkerMonitoring
    
  def load_user_favorites user_id
    #my_progress = 0

    current_user = User.find_by_id(user_id.to_i)
    
    #record_progress(my_progress)

    current_user.load_favorites
    #while(my_progress < 100)
    #  my_progress += 1
    #  record_progress(my_progress)
    #  sleep 1
    #end
    
    #record_progress(100)
  end
end