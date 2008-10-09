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
      flash[:notice] = "Login Incorrect"
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
      flash[:notice] = "It looks like you're trying to activate an account.  Perhaps have already activated this account?" 
    end
  end

end
