class FavouritesController < ApplicationController
  before_filter :login_required
  
  def index
    @current_page  = params[:page].to_i.zero? ? 1 : params[:page].to_i
    @max_page = (current_user.favourites.count.to_f / Favourite.per_page).ceil
    @current_page = @max_page if @current_page > @max_page
    if current_user.favourites.count > 0
      @favourites = current_user.favourites.paginate(:all, :page => @current_page)
    else
      @favourites = nil
    end
    @tag_options = [["Tags", ""]]
    current_user.tags.each do |tag|
      @tag_options << [tag.name, tag.id]
    end
    @tag_options << ["New tag...", "new"]
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
  
  def tag
    if request.post?
      if params[:tag_choices] =~ /^\d+$/
        tag = Tag.find(params[:tag_choices])
        params.each do |param|
          if param[0].include?('tweet_')
            tweet = Favourite.find(param[1])
            tweet.tags << tag
            tweet.save
          end
        end
        redirect_to favourites_url
      elsif params[:tag_choices] == "new"
        @tweets = []
        params.each do |param|
          if param[0].include?('tweet_')
            @tweets << param[1]
          end
        end
      end
    end
  end
  
  def new_tag
    if request.post?
      affected_tweets = params[:faves]
      tag_name = params[:tag_name]
      tag = nil
      unless tag_name.nil?
        tag = Tag.find_by_name_and_user_id(tag_name, current_user.id)
        unless tag
          tag = Tag.create(:name => tag_name, :user_id => current_user.id)
          if affected_tweets
            tweets = affected_tweets.split(",")
            tweets.each do |tweet_id|
              tweet = Favourite.find(tweet_id)
              if tweet
                tweet.tags << tag
                tweet.save
              end
            end
          end
        end 
      end
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
    @tags = current_user.tags
    @tweets = current_user.favourites.paginate_by_twitterer_name(twitterer, :page => @current_page)
  end
end
