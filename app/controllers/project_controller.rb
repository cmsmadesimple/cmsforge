class ProjectController < ApplicationController
  
  before_filter :login_required, :only => [ :register, :admin, :demote, :promote, :remove_from_project, :update_package ]
  
  def view
    @project = Project.find_by_unix_name(params[:unix_name]) || Project.find_by_id(params[:id])
  end
  
  def register
    unless params[:cancel].nil?
      redirect_to :action => 'view', :controller => 'account'
      return
    end
    unless params[:project].nil?
      @project = Project.new(params[:project])
      unless @project.valid?
        render :action => 'register'
      else
        @project.save
        redirect_to :action => 'complete'
      end
    end
  end
  
  def admin
    @project = Project.find_by_id(params[:id])
    unless logged_in? and current_user.admin_of?(@project)
      redirect_to :action => 'view', :id => params[:id]
    end
    
    unless params[:project].nil?
      @project.update_attributes(params[:project])
      if @project.valid?
        @project.save
        flash[:message] = 'Project Updated'
      end
    end
  end
  
  def demote
    @project = Project.find_by_id(params[:id])
    unless logged_in? and current_user.admin_of?(@project)
      redirect_to :action => 'view', :id => params[:id] and return
    end
    
    assign = Assignment.find_by_id(params[:assignment_id])
    unless assign.nil? or assign.project_id != @project.id
      assign.role = 'Member'
      assign.save
      flash[:message] = 'User Demoted to Member'
    else
      flash[:notice] = 'There was an error demoting the user'
    end

    redirect_to :action => 'admin', :id => params[:id]
    
  end
  
  def promote
    assign = Assignment.find_by_id(params[:id])
    unless assign.nil?

      @project = assign.project
      unless current_user.admin_of?(@project)
        redirect_to :action => 'view', :id => @project.id and return
      end

      assign.role = 'Administrator'
      assign.save
      flash[:message] = 'User Promoted to Administrator'

      redirect_to :action => 'admin', :id => @project.id
    else
      flash[:notice] = 'There was an error promoting the user'
    end
    
  end
  
  def add_to_project
    @project = Project.find_by_id(params[:id])
    unless logged_in? and current_user.admin_of?(@project)
      redirect_to :action => 'view', :id => params[:id] and return
    end
    
    user = User.find_by_login(params[:login])
    unless user.nil?
      assign = Assignment.new
      assign.user_id = user.id
      assign.project_id = @project.id
      assign.role = 'Member'
      assign.save
      flash[:message] = 'User Added to Project'
    else
      flash[:notice] = 'User could not be found'
    end
    redirect_to :action => 'admin', :id => params[:id]
    
  end
  
  def remove_from_project
    @project = Project.find_by_id(params[:id])
    unless logged_in? and current_user.admin_of?(@project)
      redirect_to :action => 'view', :id => params[:id] and return
    end

    flash[:message] = 'User Removed from Project'
    redirect_to :action => 'admin', :id => params[:id]
    
  end
  
  def update_package
    @project = Project.find_by_id(params[:project_id])
    unless @project.nil? or !current_user.admin_of?(@project)
      package = Package.find_by_id(params[:id])
      unless package.nil?
        package.update_attributes(params[:package])
        if package.valid? and package.save
          flash[:message] = 'Package Updated'
        else
          flash[:warning] = 'There was an error updating the package'
        end
      else
        flash[:warning] = 'There was an error updating the package'
      end
    end
    
    redirect_to :action => 'admin', :id => params[:project_id]
  end
  
end