# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  #include HoptoadNotifier::Catcher

  include AuthenticatedSystem
  before_filter :login_from_cookie
  before_filter :instantiate_controller_and_action_names

  # Pick a unique cookie name to distinguish our session data from others'  
  #session :session_key => '_cmsforge_session_id'

  def instantiate_controller_and_action_names
    @current_action = action_name
    @current_controller = controller_name
  end
  
  def render_404
    respond_to do |format|
      format.html { render :file => "#{RAILS_ROOT}/public/404.html", :status => '404 Not Found' }
      format.rss { render :nothing => true, :status => '404 Not Found' }
      format.xml { render :nothing => true, :status => '404 Not Found' }
    end
    true
  end
  
  EXCEPTIONS_NOT_LOGGED = ['ActionController::UnknownAction',
                           'ActionController::RoutingError']

  protected
    def log_error(exc)
      super unless EXCEPTIONS_NOT_LOGGED.include?(exc.class.name)
    end

end
