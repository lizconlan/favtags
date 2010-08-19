require File.dirname(__FILE__) + '/../spec_helper'

describe FavoritesController do
  before do
    @current_user = mock_model(User)
    controller.stub!(:current_user).and_return(@current_user)
    
    fave1 = mock_model(Favorite)
    fave2 = mock_model(Favorite)
    @faves = [fave1, fave2]
  end
  
  describe "when asked for the index page" do
    describe "and not passed an account or tag parameter" do
      it 'should assign default values if the user has no stored favorites' do
        @current_user.should_receive(:favorites).and_return({})
        @current_user.should_receive(:tags).and_return([])
        
        get :index
        
        assigns[:favorites].should == nil
        assigns[:current_page].should == 1
        assigns[:max_page].should == 1
      end
      
      it 'should assign calculated values if the user has stored favorites' do
        tag = mock_model(Tag)
        @faves.should_receive(:paginate).with(:all, :page => 1)
        @current_user.should_receive(:favorites).at_least(1).times.and_return(@faves)
        @current_user.should_receive(:tags).and_return([mock_model(Tag, :name => 'test', :id => 1)])
        
        get :index
        
        assigns[:max_page].should == 1
        assigns[:show_twitterer].should be_true
      end
    end

    describe "and passed an account parameter" do
      it 'should assign calculated values' do
        account_name = "dave"
        @faves.should_receive(:find_all_by_twitterer_name).with(account_name).and_return(@faves)
        @faves.should_receive(:paginate_by_twitterer_name).with(account_name, :page => 1).and_return(@faves)
        @current_user.should_receive(:favorites).at_least(1).times.and_return(@faves)
        @current_user.should_receive(:tags).and_return([mock_model(Tag, :name => 'test', :id => 1)])
        
        get :index, :account => "dave"
        
        assigns[:max_page].should == 1
        assigns[:favorites].should == @faves
      end
    end
    
    describe "and passed a tag parameter" do
      it 'should assign calculated values' do
        tag = "test"
        Favorite.should_receive(:find_all_by_tag_name_and_user_id).with(tag, @current_user.id).and_return(@faves)
        @current_user.should_receive(:tags).and_return([mock_model(Tag, :name => 'test', :id => 1)])
        
        get :index, :tag => "test"
      end
    end
  end

  describe "when asked to load favorites" do
    before do
      @current_user.stub!(:save!)
      @current_user.should_receive(:job_id).at_least(1).times.and_return(42)
    end
    
    it 'should attempt to load the last job if the user has a stored job id' do
      dj = mock_model(Delayed::Job)
      dj.stub!(:failed?).and_return(false)
      Delayed::Job.should_receive(:find).and_return(dj)
      
      get :load
    end
    
    it 'should start a new DelayedJob if the previous one has failed' do
      dj = mock_model(Delayed::Job)
      dj.stub!(:failed?).and_return(true)
      Delayed::Job.should_receive(:find).and_return(dj)
      
      job = mock_model(LoadingJob)
      LoadingJob.should_receive(:new).with(@current_user.id).and_return(job)
      new_dj = mock_model(Delayed::Job)
      Delayed::Job.should_receive(:enqueue).with(job).and_return(new_dj)
      @current_user.should_receive(:job_id=).with(new_dj.id)
      
      get :load
    end
    
    it 'should recover elegantly if retrieving a Delayed Job fails' do
      job = mock_model(LoadingJob)
      LoadingJob.should_receive(:new).with(@current_user.id).and_return(job)
      new_dj = mock_model(Delayed::Job)
      Delayed::Job.should_receive(:enqueue).with(job).and_return(new_dj)
      @current_user.should_receive(:job_id=).with(new_dj.id)
      Delayed::Job.should_receive(:find).and_raise("error")
      
      get :load
    end
    
    it 'should redirect to the favorites page' do
      dj = mock_model(Delayed::Job)
      dj.stub!(:failed?).and_return(false)
      Delayed::Job.should_receive(:find).and_return(dj)
      
      get :load
      response.should redirect_to(:controller => 'favorites', :action => 'index')
    end
  end
end