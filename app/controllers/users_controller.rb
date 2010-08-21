class UsersController < ApplicationController
  before_filter :login_required
  
  def index
    if request.post?
      if request["autocreate"] == "1"
        current_user.autocreate_tags = true
      else
        current_user.autocreate_tags = false
      end
      tweets = request["tweets"].to_i
      if tweets > 0
        current_user.pages_to_load = tweets
      end
      current_user.save
    end
  end
  
  def leave
    if request.post?
      current_user.delete_favorites
      current_user.delete
      redirect_to "/exit"
    end
  end
end