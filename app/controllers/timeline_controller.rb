class TimelineController < ApplicationController
  before_filter :login_required
  
  def index
    current_user.load_favorites
    page = params[:page]
    if page
      @tweets = current_user.twitter.get("/favorites?page=#{page}") 
    else
      @tweets = current_user.twitter.get('/favorites') 
    end
  end
end
