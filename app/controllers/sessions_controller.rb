class SessionsController < ApplicationController
  
  def new    
  end
  
  def show
    @sessions = Session.where(:user_id => params[:user_id]).paginate(:page => params[:page]).order('time DESC')
  end
  
  def create
    user = User.authenticate(params[:session][:email], params[:session][:password])

    if user.nil?
      flash.now[:error] = "Invalid email/password combination"
      render :new
    else
      sign_in user
      redirect_back_or user
      user.sessions.build(:time => Time.now) # Log the session
      user.update_attributes(:last_login => Time.now, :password => params[:session][:password]) # Need to send password to keep functionality
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
end
