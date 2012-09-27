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
    if params[:user][:password].empty?
      success = @user.update_attribute(:admin, params[:user][:admin])
    else 
      @user.password = params[:user][:password]
      @user.encrypt_password
      success = @user.update_attributes(params[:user])  
    end
    
    if success
      redirect_to @user, :flash => { :success => "Profile updated!" }
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
      @user.sessions.clear
      @user.destroy
    end
    redirect_to users_path
  end

  def check_availability
    @user = User.find_by_email(params[:user][:email])
    respond_to do |format|
      format.json { render :json => !@user }
    end
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
