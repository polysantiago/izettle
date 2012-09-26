require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET 'index'" do
    
    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
      end
    end
    
    describe "for signed-in users" do
      before(:each) do
        @user  = test_sign_in(Factory(:user))
        @admin = test_sign_in(Factory(:admin))
      end
      
      it "should be deny access for non-admin users" do
        get :index
        response.should be_success
      end
           
    end
    
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'create'" do
    it "returns http success" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'destroy'" do
    it "returns http success" do
      get 'destroy'
      response.should be_success
    end
  end

end
