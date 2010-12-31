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
  
  def render_not_found
    render :template => 'public/404.html', :status => 404
  end
  
  def exit
    render :template => "exit.haml"
  end
  
  private
  
    def client(access_token, access_secret)
      Twitter.configure do |config|
        config.consumer_key = TwitterAuth.config['oauth_consumer_key']
        config.consumer_secret = TwitterAuth.config['oauth_consumer_secret']
        config.oauth_token = access_token
        config.oauth_token_secret = access_secret
      end
      @client ||= Twitter::Client.new
    end
    helper_method :client
end
