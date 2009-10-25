require 'active_record'
require 'models/user.rb'
require 'models/favourite.rb'

class FavouritesLoader
  
  #include BackgroundFu::WorkerMonitoring
    
  def load_user_favourites user_id
    #my_progress = 0

    current_user = User.find_by_id(user_id.to_i)
    
    #record_progress(my_progress)

    current_user.load_favourites
    #while(my_progress < 100)
    #  my_progress += 1
    #  record_progress(my_progress)
    #  sleep 1
    #end
    
    #record_progress(100)
  end
end