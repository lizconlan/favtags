class TimelineController < ApplicationController
  before_filter :login_required
  
  def index
    @tweets = current_user.twitter.get('/favorites') 
  end
end
