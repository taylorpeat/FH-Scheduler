class SessionsController < ApplicationController

  def new
    if logged_in?
      flash[:success] = "You are already logged in."
      redirect_to root_path
    end
  end

  def create
    user = User.find_by_username(params[:username])
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        flash[:success] = "Logged in successfully."
        redirect_to rosters_path
      else
        flash[:danger] = "There was a problem with your username or password."
        render 'new'
      end 
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = "Logged out successfully."
    redirect_to root_path
  end

end