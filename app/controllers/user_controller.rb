class UserController < ApplicationController

  before_filter :authenticate_user!, :except => [ :show, :forgot_password, :reset_password ]

  #def index
    #@users = User.excludes(:id => current_user.id)
  #end

  def show
    @user = User.where(:login => params[:id]).first
  end

  #def new
    #@user = User.new
  #end

  #def create
    #@user = User.new(params[:user])
    #if @user.save
      #flash[:notice] = "Successfully created User." 
      #redirect_to root_path
    #else
      #render :action => 'new'
    #end
  #end

  def edit
    @user = User.where(:login => params[:id]).first
  end

  def update
    @user = User.find(params[:id])
    params[:user].delete(:password) if params[:user][:password].blank?
    params[:user].delete(:password_confirmation) if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated User."
      redirect_to root_path
    else
      render :action => 'edit'
    end
  end

  #def destroy
    #@user = User.find(params[:id])
    #if @user.destroy
      #flash[:notice] = "Successfully deleted User."
      #redirect_to root_path
    #end
  #end
  #

  def add_key
    @action = 'add_key'
    @user = current_user
    if @user.nil?
      redirect_to('/')
    end
    @key = SshKey.new
    @key.user_id = @user.id
    if params[:commit]
      @key.name = params[:key][:name]
      @key.key = params[:key][:key]
      if @key.save
        flash[:notice] = 'Key Successfully Added -- it will be available to use within 15 minutes'
        redirect_to('/users/' + @user.login + "/edit") and return
      end
    end
    render :action => 'edit_key'
  end
  
  def edit_key
    @action = 'edit_key'
    @user = current_user
    if @user.nil?
      redirect_to('/')
    end
    @key = SshKey.find_by_id(params[:id])
    if params[:commit] and @key.user.id = current_user.id
      @key.name = params[:key][:name]
      @key.key = params[:key][:key]
      if @key.save
        flash[:notice] = 'Key Successfully Updated -- it will be available to use within 15 minutes'
        redirect_to('/users/' + @user.login + "/edit") and return
      end
    end
  end
  
  def delete_key
    @user = current_user
    if @user.nil?
      redirect_to('/')
    end
    @key = SshKey.find_by_id(params[:id])
    if @key.user.id = current_user.id
      SshKey.delete(@key.id)
      flash[:notice] = 'Key Successfully Deleted'
    end
    redirect_to('/users/' + @user.login + "/edit") and return
  end

end
