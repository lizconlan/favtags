# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  def index
    if current_user
      redirect_to :controller => 'favorites'
    else
      render :template => 'index.haml'
    end
  end
  
  def credits
    render :template => 'credits.haml'
  end
end
