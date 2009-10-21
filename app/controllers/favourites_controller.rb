class FavouritesController < ApplicationController
  before_filter :login_required
  
  def index
    # @tweets = current_user.tweets
    @favourites = current_user.twitter.get('/favorites')
  end
  
  def load_faves
    current_user.update_favorites
    redirect_to :index
  end
end
