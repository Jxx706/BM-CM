class UsersController < ApplicationController
  
  skip_before_filter :verify_authenticity_token, :only => [:create, :update, :handle_deletion_mark]
  
  def home
    @title = 'Usuarios'
  end

  def new
    @title = "Nuevo usuario"
    @user = User.new
  end

  def create
    params[:user][:super_admin] = params[:user][:super_admin] == "1" #If 1, then super_admin. Otherwise, not.
    @user = User.new(params[:user])

    if @user.save then
      redirect_to @user
    else
      render :action => :new
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user]) then
      redirect_to root_path
    else
      render :action => :edit
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def show
    @user = User.find(params[:id])
    @title = "#{@user.name} #{@user.last_name}"
  end

  def handle_deletion_mark
    @user = User.find(params[:id])

    if @user.toggle!("marked_as_deletable") then
      redirect_to root_path
    else
      redirect_to :root 
    end
  end

  #This actions is only available for Super-Admins
  def destroy
    @user = User.find(params[:id])

    #Remove this user's directory.
    if Dir.exists?(@user.directory_path) then
      entries = Dir.entries(@user.directory_path)
      entries.delete(".")
      entries.delete("..")
      entries.each do |e|
        File.delete(e)
      end

      Dir.rmdir(@user.directory_path)
    end

    path = root_path
    #Remove the user from DB.
    if current_user.id != @user.id then 
      path = users_path
    end

    @user.destroy
    redirect_to path
  end

  #This action is only available for Super-Admins
  def index
    @title = "Todos los usuarios"
    @users = User.all
  end

  #This action is only available for Super-Admins
  def index_nodes
    user = User.find(params[:user_id])
    @nodes = ["#{user.name} #{user.last_name}", user.nodes]
  end

  #This action is only available for Super-Admins
  def index_flows
    user = User.find(params[:user_id])
    @flows = ["#{user.name} #{user.last_name}", user.flows]
  end
end
