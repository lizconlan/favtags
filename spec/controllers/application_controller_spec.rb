require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do
  
  describe "when finding route for action" do
    it 'should display page not found for unknown routes' do
      params_from(:get, "/bad_url").should == {:controller => "application", :action => "render_not_found", :bad_route=>['bad_url']}
      
      get "render_not_found"
      response.should render_template('public/404.html')
    end
  end
  
  describe "when asked for the credits page" do
    it 'should render the credits haml file' do
      get :credits
      response.should render_template('credits')
    end
  end
  
  describe "when asked for the index page" do
    it 'should render the index page if there is no logged in user' do
      get :index
      response.should render_template('index')
    end
    
    it 'should redirect to the favorites index if there is a logged in user' do
      @current_user = mock_model User
      controller.stub!(:current_user).and_return(@current_user)
      
      get :index
      response.should redirect_to(:controller => 'favorites', :action => 'index')
    end
  end
end