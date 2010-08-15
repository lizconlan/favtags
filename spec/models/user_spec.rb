require File.dirname(__FILE__) + '/../spec_helper'
describe User do
  describe 'when asked to delete favorites' do
    it 'should delete all stored favorites for current user' do
      fave1 = mock_model(Favorite)
      fave2 = mock_model(Favorite)
      user = User.new(:favorites => [fave1, fave2])
      user.favorites.should_receive(:destroy_all)
      
      user.delete_favorites
    end
  end
  
  describe 'when asked to update favcount' do
    it 'should replace the current stored count with the value held by Twitter' do
      auth = mock_model(TwitterAuth)
      user = User.new(:twitter_id => '1313123')
      user.should_receive(:twitter).exactly(2).times.and_return(auth)
      user.twitter.should_receive(:get).and_return({:favourites_count => 23})
      user.should_receive(:favorites_count=)
      user.should_receive(:save!)
      
      user.update_favcount
    end
  end
  
  describe 'when asked to load favorites' do
    it 'should do stuff' do
      user = User.new(:id => 1, :twitter_id => '1313123')
      auth = mock_model(TwitterAuth)
      tweet = {"coordinates"=>nil, "truncated"=>false, "favorited"=>true, "created_at"=>"Sat Jan 30 18:49:55 +0000 2010", "text"=>"Hello. Big thanks to David and Catherine for stepping in on Radio 2. I have been given Tamiflu by the doctor. Still feel ghastly.", "contributors"=>nil, "id"=>8420989527, "geo"=>nil, "in_reply_to_user_id"=>nil, "user"=>{"profile_background_tile"=>false, "name"=>"jonathan ross", "profile_sidebar_border_color"=>"87bc44", "profile_sidebar_fill_color"=>"e0ff92", "profile_image_url"=>"http://a1.twimg.com/profile_images/730395418/aaa_normal.jpg", "location"=>"London", "created_at"=>"Sun Nov 30 11:53:25 +0000 2008", "profile_link_color"=>"0000ff", "contributors_enabled"=>false, "favourites_count"=>11, "url"=>nil, "utc_offset"=>12600, "id"=>17753033, "lang"=>"en", "protected"=>false, "profile_text_color"=>"000000", "followers_count"=>529563, "profile_background_color"=>"96FAFA", "notifications"=>false, "time_zone"=>"Tehran", "verified"=>false, "description"=>"Lord Goo Goo", "geo_enabled"=>false, "statuses_count"=>10239, "friends_count"=>4062, "profile_background_image_url"=>"http://a1.twimg.com/profile_background_images/33755974/Wossy_1251842897.jpg", "following"=>false, "screen_name"=>"Wossy"}, "source"=>"<a href=\"http://www.tweetdeck.com/\" rel=\"nofollow\">TweetDeck</a>", "place"=>nil, "in_reply_to_screen_name"=>nil, "in_reply_to_status_id"=>nil}
      user.should_receive(:twitter).exactly(2).times.and_return(auth)
      user.should_receive(:update_favcount)
      auth.should_receive(:get).with("/favorites.json?page=1").and_return([tweet])
      auth.should_receive(:get).with("/favorites.json?page=2").and_return("")
      Favorite.should_receive(:find_by_tweet_id_and_user_id).and_return nil
      
      user.load_favorites
    end
  end
  
  describe 'when asked for a list of faved twitterers' do
    it 'should return an array of twitter names sorted in alphabetical order' do
      fave1 = Favorite.new(:twitterer_name => 'xtest')
      fave2 = Favorite.new(:twitterer_name => 'atest')
      user = User.new(:favorites => [fave1, fave2])
      user.faved_accounts.should == [{:count => 1, :name => "atest"}, {:count => 1, :name => "xtest"}]
    end
    
    it 'should correctly report the tally of tweets per account' do
      fave1 = Favorite.new(:twitterer_name => 'xtest')
      fave2 = Favorite.new(:twitterer_name => 'atest')
      fave3 = Favorite.new(:twitterer_name => 'xtest')
      user = User.new(:favorites => [fave1, fave2, fave3])
      user.faved_accounts.should == [{:count => 1, :name => "atest"}, {:count => 2, :name => "xtest"}]
    end
  end
  
  describe 'when asked whether a user has already used a particular tag' do
    it 'should return true if the tag is in current use' do
      user = User.new(:tags => [mock_model(Tag, :name => 'test')])
      user.has_tag?('test').should == true
    end
    
    it 'should return false if the tag is not in current use' do
      user = User.new(:tags => [])
      user.has_tag?('test').should == false
    end
  end
end