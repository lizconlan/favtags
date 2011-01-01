class TagsController < ApplicationController
  before_filter :login_required
  
  def index
    @tags = current_user.tags
  end
  
  def delete
    tag_name = params[:tag].gsub("--", "|").gsub("-", " ").gsub("|", "-")
    tag = Tag.find_by_name_and_user_id(tag_name, current_user.id)
    tag.delete
    
    
    redirect_to '/favorites/tags'
  end
  
  def rename
    if request.post?
      tag = params[:tag].gsub("--", "|").gsub("-", " ").gsub("|", "-")
      chosen = params[:new_name]
      
      if Tag.find_by_name_and_user_id(chosen, current_user.id)
        @error = "You already have a tag called #{chosen}, please chose a different name"
      else
        tag = Tag.find_by_name_and_user_id(tag, current_user.id)
        tag.name = chosen
        tag.save
        redirect_to "/favorites/tags"
      end
    end
  end
  
  def merge
    unless request.post?
      redirect_to "/favorites/tags"
    end
    
    @tags = []
    params.each do |param|
      if param[0].include?('tag_')
        @tags << Tag.find(param[1])
      end
    end
    
    if params[:into]
      into = Tag.find(params[:into])
      @tags.each do |tag|
        unless tag.name == into.name
          tag.favorites.each do |fave|
            fave.detag(tag.name)
            fave.tag(into.name, current_user.id)
          end
          tag.delete
        end
      end
      redirect_to "/favorites/tags"        
    end
    
    if @tags.count < 2
      @error = "You must choose more than 1 tag to merge!"
    end
  end
  
end