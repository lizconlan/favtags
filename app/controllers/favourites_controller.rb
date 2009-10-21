class FavouritesController < ApplicationController
  before_filter :login_required
  
  def index
    # @favourites = current_user.twitter.get('/favorites')
    @favourites = current_user.favourites
  end
  
  def load
    current_user.load_favourites
    redirect_to :action => "index"
  end
end
