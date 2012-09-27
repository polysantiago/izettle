require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'index'" do

    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
      end
    end
    
    describe "for signed-in-users" do

      before(:each) do
        @user = FactoryGirl.build(:user)
        @user.encrypt_password
        @user.save!
        @user = test_sign_in(@user)
      end      
      
      it "should deny access for non-admin users" do
        get :index
        response.should redirect_to(root_path)
      end
      
      it "should have delete links for admins" do
        @user.toggle!(:admin)
        other_user = FactoryGirl.create(:user, :email => "another@example.com")
        get :index
        response.should have_selector('form', :method => "post", :action => user_path(other_user)) do |form|
          form.should have_selector('input', :value => 'Delete')
        end
      end
      
      it "should have not have a delete links for itself" do
        @user.toggle!(:admin)
        get :index
        response.should_not have_selector('form', :method => "post", :action => user_path(@user))
      end      
    end
  end

  describe "GET 'show'" do
    
    before(:each) do
        @user = FactoryGirl.build(:user)
        @user.encrypt_password
        @user.save!
        @user = test_sign_in(@user)
    end
  
    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
    
    it "should have the user's email" do
      get :show, :id => @user
      response.should have_selector('span', :content => @user.email)
    end        
    
  end

  describe "GET 'new'" do
  
    it "should be successful" do
      get :new
      response.should be_success
    end
  end
  
  describe "POST 'create'" do

    describe "failure" do
      
      before(:each) do
        @attr = { :email => "", :password => "", :password_confirmation => "" }
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :email => "user@example.com",:password => "foobar", :password_confirmation => "foobar" }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end
      
      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome to iZettle/i
      end
      
      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end
  end
  
  describe "GET 'edit'" do
    
    before(:each) do
      @user = FactoryGirl.create(:user)
      test_sign_in(@user)
    end
    
    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end
  end

  describe "PUT 'update'" do
      
    before(:each) do
      @user = FactoryGirl.build(:user)
      @user.encrypt_password
      @user.save!
      test_sign_in(@user)
    end

    describe "failure" do
      
      before(:each) do
        @attr = { :email => "user@example.org", :password => "aaaaaaa", :password_confirmation => "bbbbbb" }
      end
      
      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end
      
    end

    describe "success" do
      
      before(:each) do
        @attr = { :password => "barbaz", :password_confirmation => "barbaz" }
      end
      
      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.encrypted_password.should == assigns(:user).encrypted_password
      end
      
      it "should let an user log back in after changing its password" do
        original_password = @user.password
        put :update, :id => @user, :user => @attr        
        @user.reload
        User.authenticate(@user.email, original_password).should be_nil
        User.authenticate(@user.email, @attr[:password]).should_not be_nil
        controller.should be_signed_in
        test_sign_out
        test_sign_in(@user)
        controller.should be_signed_in
      end
      
      it "should change toogle user to be an admin if password is empty" do
        put :update, :id => @user, :user => { :email => @user.email, :password => "", :password_confirmation => "", :admin => true }
        @user.reload
        @user.should be_admin
      end
      
      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end

  describe "authentication of edit/update actions" do
    
    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    describe "for non-signed-in users" do

      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    
      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do
      
      before(:each) do
        wrong_user = FactoryGirl.create(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end
      
      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
      
      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end

  describe "DELETE 'destroy'" do
    
    before(:each) do
      @user = FactoryGirl.create(:user)
    end
    
    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end
    
    describe "as non-admin user" do
      it "should protect the action" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end
    
    describe "as an admin user" do
      
      before(:each) do
        @admin = FactoryGirl.create(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(@admin)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end
      
      it "should redirect to the users page" do
        delete :destroy, :id => @user
        flash[:success].should =~ /destroyed/i
        response.should redirect_to(users_path)
      end
      
      it "should not be able to destroy itself" do
        lambda do
          delete :destroy, :id => @admin
        end.should_not change(User, :count)
      end
    end
  end
  
end