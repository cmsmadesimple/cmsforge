class AccountController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  #before_filter :login_from_cookie
  
  #before_filter :login_required, :only => [ :view ]

  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end
  
  def view
    login = params[:login]
    @user = User.find_by_login(login)
    if @user.nil?
      redirect_to('/')
    end
  end
  
  def edit
    login = params[:login]
    @user = User.find_by_login(login)
    if @user.nil? or (current_user.id != @user.id and !current_user.superuser)
      redirect_to('/')
    end
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/account', :action => 'view')
      flash[:notice] = "Logged in successfully"
    else
      flash.now[:warning] = "Login Incorrect"
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    #self.current_user = @user
    #redirect_back_or_default(:controller => '/account', :action => 'index')
    #flash[:notice] = "Thanks for signing up!"
    render :action => 'thanks'
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to('/')
  end
  
  def activate
    @user = User.find_by_activation_code(params[:id]) if params[:id]
    if @user and @user.activate
      self.current_user = @user
      redirect_back_or_default(:controller => '/account', :action => 'view')
      flash[:notice] = "Your account has been activated." 
    else
      redirect_back_or_default(:controller => 'home', :action => 'index')
      flash[:warning] = "It looks like you're trying to activate an account.  Perhaps have already activated this account?" 
    end
  end
  
  def update
    @user = User.find_by_id(params[:user][:id])
    if !@user.nil? and (@user.id == current_user.id or current_user.superuser)
      @user.update_attributes(params[:user])
      if @user.valid?
        if @user.save
          flash.now[:notice] = "User Details Succesfully Updated"
        end
      end
    else
      redirect_to('/')
    end

    render :action => 'edit'
  end
  
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
