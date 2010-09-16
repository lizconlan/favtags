class TagsController < ApplicationController
  before_filter :login_required
  
  def delete
    tag_name = params[:tag]
    tag = Tag.find_by_name_and_user_id(tag_name, current_user.id)
    tag.delete
    
    if params[:page] && params[:page] != "1"
      redirect_to :action => 'index', :page => params[:page]
    else
      redirect_to :action => 'index', :controller => 'favorites'
    end
  end
end