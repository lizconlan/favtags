class FavoritesController < ApplicationController
  before_filter :login_required
  
  def index
    @account = params[:account]
    tag_name = params[:tag]
    unless tag_name.nil?
      @tag = tag_name.gsub("-", " ").gsub("  ", "-")
    end
    
    @current_page = params[:page].to_i.zero? ? 1 : params[:page].to_i
    @current_page = 1 if @current_page.nil?
        
    
    if @account
      @max_page = (current_user.favorites.find_all_by_twitterer_name(@account).count.to_f / Favorite.per_page).ceil
      @max_page = 1 if @max_page == 0
      @current_page = @max_page if @current_page > @max_page
      @favorites = current_user.favorites.paginate_by_twitterer_name(@account, :page => @current_page)
    elsif @tag
      @show_twitterer = true
      tagged_faves = Favorite.find_all_by_tag_name_and_user_id(@tag, current_user.id)
      
       respond_to do |format|
          format.html do ||
            @max_page = (tagged_faves.count.to_f / Favorite.per_page).ceil
            @max_page = 1 if @max_page == 0
            @current_page = @max_page if @current_page > @max_page
            @favorites = tagged_faves.paginate(:page => @current_page, :order => 'posted DESC')
          end
          @favorites = tagged_faves
          format.xml { render :action => "gen_xml.rxml", :layout => false }
          format.json { render :json => tagged_faves }
          format.js { render :json => tagged_faves }
        end
    elsif current_user.favorites.count > 0
      @show_twitterer = true
      
      respond_to do |format|
        format.html do ||
          @max_page = (current_user.favorites.count.to_f / Favorite.per_page).ceil
          @max_page = 1 if @max_page == 0
          @current_page = @max_page if @current_page > @max_page
          @favorites = current_user.favorites.paginate(:all, :page => @current_page)
        end
        @favorites = current_user.favorites
        format.xml { render :action => "gen_xml.rxml", :layout => false }
        format.json { render :json => current_user.favorites.to_json }
        format.js { render :json => current_user.favorites.to_json }
      end
    else
      @favorites = nil
      @current_page = 1
      @max_page = 1
    end
    
    @tag_options = [["Apply tags", ""]]
    current_user.tags.each do |tag|
      @tag_options << [tag.name, tag.id]
    end
    @tag_options << ["New tag...", "new"]
  end
  
  def load
    if request.post?
      if current_user.job_id
        begin
          @job = Delayed::Job.find(current_user.job_id)
        rescue
          @job = nil
        end
      end
    
      if !@job || @job.failed?
        @job = Delayed::Job.enqueue(LoadingJob.new(current_user.id))
        current_user.job_id = @job.id
        current_user.save!
      end
    
      redirect_to favorites_url
    end
  end
  
  def tag
    if request.post?
      if params[:tag_choices] =~ /^\d+$/
        tag = Tag.find(params[:tag_choices])
        params.each do |param|
          if param[0].include?('tweet_')
            tweet = Favorite.find(param[1])
            tweet.tag(tag.name, current_user.id)
          end
        end
        action = params[:from]
        page = params[:page]
        page = 1 if page.to_i == 0
        if params[:account] != ""
          redirect_to :action => 'index', :page => page, :account => params[:account]
        elsif params[:tag] != ""
          redirect_to :action => 'index', :page => page, :tag => params[:tag]
        else
          redirect_to :action => 'index', :page => page
        end
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
  
  def accounts
    @accounts = current_user.faved_accounts
  end
  
  def tags
    @tags = current_user.tags
  end
  
  def new_tag
    if request.post?
      affected_tweets = params[:faves]
      tag_name = params[:tag_name]
      tag = nil
      unless tag_name.nil?
        tag = Tag.find_by_name_and_user_id(tag_name, current_user.id)
        unless tag
          if tag_name =~ /^[a-zA-Z0-9\-\ ]+$/
            tag_name = tag_name.squeeze(" ")
            tag = Tag.create(:name => tag_name, :user_id => current_user.id)
            if affected_tweets
              tweets = affected_tweets.split(",")
              tweets.each do |tweet_id|
                tweet = Favorite.find(tweet_id)
                if tweet
                  tweet.tags << tag
                  tweet.save
                end
              end
            end
          else
            @fail_tag = tag_name
            @tweets = affected_tweets.split(",")
            render :template => 'favorites/tag.haml'
          end
        end 
      end
    end
    
    unless @fail_tag
      redirect_to :action => 'index', :page => params[:page]
    end
  end
  
  def remove_tag
    tag_name = params[:tag]
    tweet_id = params[:id]
    
    tweet = Favorite.find_by_id_and_user_id(tweet_id, current_user.id)
    if tweet
      tweet.detag(tag_name)
    end
    if params[:account]
      redirect_to :action => 'index', :page => params[:page], :account => params[:account]
    elsif params[:tags]
      redirect_to :action => 'index', :page => params[:page], :tag => params[:tags]
    else
      redirect_to :action => 'index', :page => params[:page]
    end
  end
  
  def delete
    tweet_id = params[:id]
    
    tweet = Favorite.find_by_tweet_id_and_user_id(tweet_id, current_user.id)
    if tweet
      tweet.delete
    end
    if params[:account]
      redirect_to :action => 'index', :page => params[:page], :account => params[:account]
    elsif params[:tags]
      redirect_to :action => 'index', :page => params[:page], :tag => params[:tags]
    else
      redirect_to :action => 'index', :page => params[:page]
    end
  end
end
