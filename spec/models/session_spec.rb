# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  time       :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Session do

  before(:each) do
    @user = User.create( :email => "user@example.com", :password => "foobar", :password_confirmation => "foobar")
    @attr = { :time => Time.now }
  end
  
  it "should create a new instance with valid attributes" do
    @user.sessions.create!(@attr)
  end
  
  describe "user associations" do
    
    before(:each) do
      @session = @user.sessions.create(@attr)
    end
    
    it "should have a user attribute" do
      @session.should respond_to(:user)
    end
    
    it "should have the right associated user" do
      @session.user_id.should == @user.id
      @session.user.should == @user
    end
  end
  
  describe "validations" do

    it "should have a user id" do
      Session.new(@attr).should_not be_valid
    end
  end  
end
