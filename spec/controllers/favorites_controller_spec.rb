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
end