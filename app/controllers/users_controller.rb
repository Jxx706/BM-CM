class UsersController < ApplicationController
  
  def new
    @title = "Nuevo usuario"
  end

  def create

  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
  end

  def edit
  end

  def show
    @user = User.find(params[:id])
  end

  def delete
    @user = User.find(params[:id])
    @user.destroy
  end

  #This action is only available for Super-Admins
  def index
    @users = User.all
  end
end
