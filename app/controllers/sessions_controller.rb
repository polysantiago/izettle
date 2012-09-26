class SessionsController < ApplicationController
  before_filter :admin_user, :only => [:show]
  
  def show
    @sessions = Session.where(:user_id => params[:user_id]).paginate(:page => params[:page]).order('time DESC')
  end
  
  def new    
  end    
  
  def create
    user = User.authenticate(params[:session][:email], params[:session][:password])
    
    if user.nil?
      flash.now[:error] = "Invalid email/password combination"
      render :new
    else
      sign_in user
      redirect_back_or user
      user.sessions.create(:time => Time.now) # Log the session
      user.update_attribute(:last_login, Time.now)
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
  
  private 
  
    def admin_user
      flash[:error] = "You're not authorized to see other user's sessions"
      redirect_to(root_path) unless current_user.admin?
    end   
end
