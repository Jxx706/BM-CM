class UsersController < ApplicationController
  
  skip_before_filter :verify_authenticity_token, :only => [:update]
  
  def new
    @title = "Nuevo usuario"
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    if @user.save then
      redirect_to @user
    else
      render :action => :new
    end
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])

    render "show"
  end

  def edit
    @user = User.find(params[:id])
  end

  def show
    @user = User.find(params[:id])
    @title = "#{@user.name} #{@user.last_name}"
  end

  def delete
    @user = User.find(params[:id])
    @user.destroy
  end

  #This action is only available for Super-Admins
  def index
    @title = "Todos los usuarios"
    @users = User.all
  end
end
