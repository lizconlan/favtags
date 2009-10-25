class FavouritesController < ApplicationController
  before_filter :login_required
  
  def index
    @current_page  = params[:page].to_i.zero? ? 1 : params[:page].to_i
    @max_page = (current_user.favourites.count.to_f / Favourite.per_page).ceil
    @current_page = @max_page if @current_page > @max_page 
    @favourites = current_user.favourites.paginate(:all, :page => @current_page)
  end
  
  def load
    unless session[:job_id]
      session[:job_id] = Job.enqueue!(FavouritesLoader, :load_user_favourites, current_user.id).id
    else
      @job = Job.find(session[:job_id])
      if @job.finished?
        session[:job_id] = Job.enqueue!(FavouritesLoader, :load_user_favourites, current_user).id
      end
    end
  end
  
  def twitterers
    @tweeps = current_user.faved_tweeple
  end
  
  def tweep
    twitterer = params[:twitterer]
    @current_page  = params[:page].to_i.zero? ? 1 : params[:page].to_i
    @max_page = (current_user.favourites.find_all_by_twitterer_name(twitterer).count.to_f / Favourite.per_page).ceil
    @current_page = @max_page if @current_page > @max_page
    @tweets = current_user.favourites.paginate_by_twitterer_name(twitterer, :page => @current_page)
  end
end
