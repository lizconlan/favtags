class TagsController < ApplicationController
  before_filter :login_required
  
  def index
    @tags = current_user.tags
  end
  
  def delete
    tag_name = params[:tag]
    tag = Tag.find_by_name_and_user_id(tag_name, current_user.id)
    tag.delete
    
    
    redirect_to '/favorites/tags'
  end
  
  def rename
    if request.post?
      tag = params[:tag]
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
end