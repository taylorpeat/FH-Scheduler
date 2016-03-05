class UsersController < ApplicationController

  before_action :require_login, except: [:welcome, :new, :create]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :require_current_user, only: [:edit, :show, :update]

  def welcome
    @welcome = true
  end

  def new
    @user = User.new
  end

  def show
  end

  def edit
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
      flash[:danger] = "User could not be created."
      render 'new'
    end
  end

  def update
    if @user.update(user_params)
      flash[:success] = "User has been updated."
      redirect_to user_path(@user) and return
    else
      flash[:danger] = "User could not be updated."
      redirect_to edit_user_path(@user) and return
    end
  end

  private

    def user_params
      params.require(:user).permit(:username, :password)
    end

    def set_user
      @user = current_user
    end
end