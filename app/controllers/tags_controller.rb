class TagsController < ApplicationController
  before_filter :login_required
  
  def delete
    tag_name = params[:tag]
    tag = Tag.find_by_name_and_user_id(tag_name, current_user.id)
    tag.delete
    
    
    if params[:account] != ""
      redirect_to :action => 'index', :page => page, :account => params[:account]
    elsif params[:tag] != ""
      redirect_to :action => 'index', :page => page, :tag => params[:tag]
    else
      redirect_to :action => 'index', :page => page
    end
  end
end