class TimelineController < ApplicationController
  before_filter :login_required
  
  def index
    @tweets = current_user.tweets
  end
end
