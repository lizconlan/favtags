class FavouritesController < ApplicationController
  before_filter :login_required
  
  def index
    @current_page  = params[:page].to_i.zero? ? 1 : params[:page].to_i
    @max_page = (current_user.favourites.count.to_f / Favourite.per_page).ceil
    @current_page = @max_page if @current_page > @max_page
    if current_user.favourites
      @favourites = current_user.favourites.paginate(:all, :page => @current_page)
    else
      @favourites = nil
    end
  end
  
  def load
    if current_user.job_id
      @job = Job.find(current_user.job_id)
    end
    
    if !@job || @job.finished? || @job.failed?
      current_user.job_id = Job.enqueue!(FavouritesLoader, :load_user_favourites, current_user.id).id
      current_user.save
      @job = Job.find(current_user.job_id)
    end

    redirect_to favourites_url
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
