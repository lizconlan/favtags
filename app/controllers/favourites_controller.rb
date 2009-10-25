class FavouritesController < ApplicationController
  before_filter :login_required
  
  def index
    # @favourites = current_user.twitter.get('/favorites')
    @favourites = current_user.favourites
  end
  
  def load
    #current_user.load_favourites
    unless session[:job_id]
      session[:job_id] = Job.enqueue!(FavouritesLoader, :load_user_favourites, current_user.id).id
    else
      @job = Job.find(session[:job_id])
      if @job.finished?
        session[:job_id] = Job.enqueue!(FavouritesLoader, :load_user_favourites, current_user).id
      end
      @progress = @job.progress
      puts @job.result
      puts @progress
    end
    #redirect_to :action => "index"
  end
  
  def twitterers
    @tweeps = current_user.faved_tweeple
  end
  
  def tweep
    twitterer = params[:twitterer]
    @tweets = current_user.favourites.find_all_by_twitterer_name(twitterer)
  end
end
