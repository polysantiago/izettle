class UsersController < ApplicationController
  before_filter :authenticate,    :only => [:index, :edit, :update, :destroy]
  before_filter :illegal_access,  :only => [:new, :create]
  before_filter :correct_user,    :only => [:edit, :update]
  before_filter :admin_user,      :only => [:index, :destroy]    

  def new
    @user = User.new    
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find params[:id]
  end

  def create
    @user = User.new params[:user]
    
    @user.registered_on = Time.now
    @user.last_login = Time.now
    @user.sessions.build(:time => Time.now)
    @user.encrypt_password       
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to iZettle!"
      redirect_to @user
    else
      render :new
    end
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user.encrypt_password
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated!"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user == current_user
      flash[:error] = "You cannot delete your own user"
    else
      flash[:success] = "User destroyed"
      @user.destroy
    end
    redirect_to users_path
  end

  private

    def authenticate
      deny_access unless signed_in?
    end
  
    def illegal_access
      redirect_to(root_path) if signed_in?
    end
  
    def correct_user
      @user = User.find params[:id]
      redirect_to(root_path) unless current_user?(@user) || current_user.admin?
    end
  
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end    
end
