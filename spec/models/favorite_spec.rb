require File.dirname(__FILE__) + '/../spec_helper'

describe Favorite do
  
  describe 'when asked for all favorites by tag_name and user_id' do
    before do
      @fave1 = mock_model(Favorite)
      @fave2 = mock_model(Favorite)
    end
    
    it 'should return an array of favorites' do
      tag = mock_model(Tag, :favorites => [@fave1, @fave2])
      Tag.should_receive(:find_by_name_and_user_id).with('test', 1).and_return(tag)
      
      Favorite.find_all_by_tag_name_and_user_id('test', 1).should == [@fave1, @fave2]
    end
    
    it 'should return an empty array if the user has no tags' do
      Tag.should_receive(:find_by_name_and_user_id).with('test', 1).and_return(nil)
      Favorite.find_all_by_tag_name_and_user_id('test', 1).should == []
    end
  end

  describe 'when asked for hashtags' do
    it 'should return an array of hashtags found in the text' do
      fave = Favorite.new()
      fave.text = "I can haz #hashtags and #morehashtags"
      fave.hashtags.should == ["hashtags", "morehashtags"]
    end
    
    it 'should not return hashtags of less than 2 characters' do
      fave = Favorite.new()
      fave.text = "this shouldn't work #a"
      fave.hashtags.should == []
    end
    
    it 'should not return numbers preceded by the hash symbol as hashtags' do
      fave = Favorite.new()
      fave.text = "this is tweet number #1000"
      fave.hashtags.should == []
    end
  end
  
  describe 'when asked for urls' do
    it 'should return an array of urls found in the text' do
      fave = Favorite.new()
      fave.text = "Links to http://favtagger.com and http://github.com/"
      fave.urls.should == ["http://favtagger.com", "http://github.com/"]
    end
    
    it 'should handle links that use the https protocol' do
      fave = Favorite.new()
      fave.text = "Links to https://example.com"
      fave.urls.should == ["https://example.com"]
    end
  end
  
  describe 'when asked for html_text' do
    it 'should make urls in the text into links' do
      fave = Favorite.new(:text => "I like http://twitter.com")
      fave.should_receive(:short_urls).at_least(1).times.and_return("")
      fave.should_receive(:short_urls=).at_least(1).times.with("")
      fave.stub!(:save)
      fave.html_text.should == 'I like <a href="http://twitter.com">http://twitter.com</a>'
    end
    
    it 'should link user names back to the relevant twitter page' do
      fave = Favorite.new(:text => "Are you following @spam on Twitter?")
      fave.html_text.should == 'Are you following <a href="http://twitter.com/spam">@spam</a> on Twitter?'
      
      fave = Favorite.new(:text => "@spam is worth following")
      fave.html_text.should == '<a href="http://twitter.com/spam">@spam</a> is worth following'
    end
    
    it 'should link hashtags to search.twitter.com' do
      fave = Favorite.new(:text => "wish I'd written these specs sooner #lazy")
      fave.html_text.should ==  'wish I\'d written these specs sooner <a href="http://search.twitter.com/search?q=%23lazy">#lazy</a>'
    end
    
    it 'should replace urls with short urls where available' do
      fave = Favorite.new(:text => "wish I\'d written these specs sooner http://favtagger.com/fake_url_goes_here", :short_urls => "http://fvt.gr/favtagger")
      fave.html_text.should ==  'wish I\'d written these specs sooner <a href="http://fvt.gr/favtagger">http://fvt.gr/favtagger</a>'
    end
  end
  
  describe 'when checking whether it has a particular tag' do
    before do
      @fave = Favorite.new()
      @fave.stub!(:tag_names => ['test', 'test2'])
    end
    
    it 'should return true if the tag is included' do
      @fave.has_tag?('test').should == true
    end
    
    it 'should return false if the tag is not included' do
      @fave.has_tag?('test1').should == false
    end
  end
  
  describe 'when asked for the tag names' do
    it 'should return a list of tag names' do
      tag1 = mock_model(Tag, :name => 'test')
      tag2 = mock_model(Tag, :name => 'test1')
      fave = Favorite.new(:tags => [tag1, tag2])
      fave.tag_names.should == ['test', 'test1']
    end
  end
  
  describe 'when asked to add a tag' do
    before do
      tag1 = mock_model(Tag)
      @fave = Favorite.new(:tags => [tag1])
    end
    
    it 'should not attempt to add the tag if the tag is already included' do
      @fave.should_receive(:has_tag?).with('test').and_return(true)
      @fave.tags.should_not_receive(:<<)
      
      @fave.tag('test', 1)
    end
    
    it 'should add the tag if the tag is not already included' do
      tag = mock_model(Tag)
      @fave.should_receive(:has_tag?).with('test').and_return(false)
      Tag.should_receive(:find_or_create_by_name_and_user_id).with('test', 1).and_return(tag)
      @fave.tags.should_receive(:<<).with(tag)
      
      @fave.tag('test', 1)
    end
  end
  
  describe 'when asked to remove a tag' do
    before do
      @tag1 = mock_model(Tag)
      @fave = Favorite.new(:tags => [@tag1])
    end
    
    it 'should do nothing if the tag is not included' do
      @fave.should_receive(:has_tag?).and_return(false)
      @fave.tags.should_not_receive(:find_by_name)
      
      @fave.detag('test')
    end
    
    it 'should remove the tag if the tag is included' do
      @fave.should_receive(:has_tag?).and_return(true)
      @fave.tags.should_receive(:find_by_name).and_return(@tag1)
      @fave.tags.should_receive(:delete).with(@tag1)
      
      @fave.detag('test')
    end
  end
  
  describe 'when asked for the utc_offset' do
    it 'should return "+0000" if no offset is found' do
      fave = Favorite.new
      fave.utc_offset.should == "+0000"
    end
  end
  
  it 'should return "-0700" if the tweet was posted from a time zone 7 hours behind GMT' do
    fave = Favorite.new(:twitterer_utc_offset => -25200)
    fave.utc_offset.should == "-0700"
  end
  
  it 'should return "+0700" if the tweet was posted from a time zone 7 hours ahead of GMT' do
    fave = Favorite.new(:twitterer_utc_offset => 25200)
    fave.utc_offset.should == "+0700"
  end
  
  describe 'when asked to shorten a url' do
    it 'should not shorten the url if it is less than 31 chars' do
      fave = Favorite.new(:text => "http://is.gd")
      fave.stub!(:save)
      fave.should_receive(:short_urls=).with("")
      
      fave.create_short_urls
    end
    
    it 'should shorten the url if it is more than 30 chars' do
      fave = Favorite.new(:text => "http://favtagger.com/fake_long_url_goes_here")
      RestClient.should_receive(:get).and_return(mock_model(RestClient::Response, :body => %Q|{"status_code":200,"data":{"hash": "d4Xucw"}}|))
      fave.stub!(:save)
      fave.should_receive(:short_urls=).with("http://fvt.gr/d4Xucw")
      
      fave.create_short_urls
    end
    
    it 'should store a blank string if the url shortening process fails' do
      fave = Favorite.new(:text => "http://favtagger.com/fake_long_url_goes_here")
      RestClient.should_receive(:get).and_return(mock_model(RestClient::Response, :body => %Q|{"status_code":500}|))
      fave.stub!(:save)
      fave.should_receive(:short_urls=).with("")
      
      fave.create_short_urls
    end
  end
  
  describe 'when asked to delete' do
    before do
      @user = User.new(:id => 1, :twitter_id => '1313123')
      @auth = mock_model(TwitterAuth)
      @user.should_receive(:twitter).at_least(1).times.and_return(@auth)
      @fave = Favorite.new(:tweet_id => '424352')
      @fave.should_receive(:user).and_return(@user)
      @tag = mock_model(Tag)
      @tags = [@tag]
    end
    
    it 'should delete the tags' do
      @fave.should_receive(:tags).at_least(1).times.and_return(@tags)
      @tags.should_receive(:delete).with(@tag)
      
      @fave.stub!(:destroy)
      @auth.stub!(:post)
      
      @fave.delete
    end
    
    it "should remove the favorite from the user's Twitter account" do
      @fave.should_receive(:tags).at_least(1).times.and_return([])
      
      @fave.stub!(:destroy)
      @auth.should_receive(:post).with("/favorites/destroy/424352")
      
      @fave.delete
    end
    
    it "should call the destroy method" do
      @fave.should_receive(:tags).at_least(1).times.and_return([])
      
      @auth.stub!(:post)
      @fave.should_receive(:destroy)
      
      @fave.delete
    end
  end
end