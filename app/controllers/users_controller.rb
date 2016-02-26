class UsersController < ApplicationController

  def welcome
    @welcome = true
  end

  def new
    @welcome = true
    @user = User.new
  end

  def create
    @user = params[:user] ? User.new(user_params) : User.new_guest

    if @user.save
      session[:user_id] = @user.id
      if @user.guest?
        flash[:success] = "Welcome Guest!"
      else
        flash[:success] = "User has been created."
      end
      redirect_to rosters_path
    else
      flash[:error] = "User could not be created."
      render 'new'
    end
  end


  private

    def user_params
      params.require(:user).permit(:username, :password)
    end
end