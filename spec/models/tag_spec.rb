require File.dirname(__FILE__) + '/../spec_helper'

describe Tag do
  describe "when asked for url" do
    it "should replace a single space with -" do
      tag = Tag.new(:name => "test tag")
      tag.url.should == "test-tag"
    end
    
    it "should replace multiple spaces with a single -" do
      tag = Tag.new(:name => "test    tag")
      tag.url.should == "test-tag"
    end
    
    it "should replace - with --" do
      tag = Tag.new(:name => "test-tag")
      tag.url.should == "test--tag"
    end
  end
end