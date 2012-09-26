require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET 'show'" do
    
    describe "for non-signed-in users" do
      it "should deny access" do       
        { :get => '/sessions' }.should_not be_routable
      end
    end
    
    describe "for signed-in users" do
      before(:each) do
        @user = FactoryGirl.build(:user)
        @user.encrypt_password
        @user.save!
        @user = test_sign_in(@user)        
      end
      
      it "should not be routable" do
        { :get => '/sessions' }.should_not be_routable
      end
      
      describe "trying to see other user's sessions" do
        
        before(:each) do
          @other_user = User.new :email => "foo@bar.se", :password => 'foobar', :password_confirmation => 'foobar'
          @other_user.encrypt_password
          @other_user.save!
          @other_user = test_sign_in(@user)   
        end
        
        it "should deny access to non-admin users" do
          get :show, :user_id => @other_user.id
          response.should redirect_to(root_path)
        end
        
        it "should allow admin user" do
          @user.toggle!(:admin)
          get :show, :user_id => @other_user.id
          response.should be_success
        end
        
      end
               
    end    
  end

  describe "GET 'new'" do
    
    it "allow access to all users" do
      get :new
      response.should be_success
    end
  
  end

  describe "GET 'create'" do
    
    describe 'failure' do
      
      before(:each) do
        @attr = { :email => "", :password => "" }
      end
      
      it "should render the login page" do
        post :create, :session => @attr
        response.should render_template('new')
      end
      
      it "should not login the user" do
        post :create, :session => @attr
        controller.should_not be_signed_in
      end
        
    end
    
    describe 'success' do
      
      before(:each) do
        @user = FactoryGirl.build(:user)
        @user.encrypt_password
        @user.save!
      end
      
      it "should go to the user home page" do
        post :create, :session => { :email => @user.email, :password => @user.password }
        response.should redirect_to(user_path(@user))
      end
      
      it "should sign in the user" do
        post :create, :session => { :email => @user.email, :password => @user.password }
        controller.should be_signed_in
      end
      
    end
    
  end

  describe "GET 'destroy'" do
    
    before(:each) do
      @user = FactoryGirl.build(:user)
      @user.encrypt_password
      @user.save!
      test_sign_in(@user)
    end    
    
    it "should logout the user" do
      delete :destroy
      controller.should_not be_signed_in
    end
    
    it "should redirect to root" do
      delete :destroy
      response.should redirect_to(root_path)
    end
    
  end

end
