class SessionsController < ApplicationController

  def new
    @welcome = true
    if logged_in?
      flash[:notice] = "You are already logged in."
      redirect_to root_path
    end
  end

  def create
    user = User.find_by_username(params[:username])
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        flash[:notice] = "Logged in successfully."
        redirect_to root_path
      else
        flash[:notice] = "There was a problem with your username or password."
        render 'new'
      end 
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Logged out successfully."
    redirect_to root_path
  end

end