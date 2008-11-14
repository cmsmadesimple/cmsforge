class AdminController < ApplicationController
  
  before_filter :login_required
  
  def authorized?
    current_user.superuser
  end
  
  def project_list
    @projects = Project.paginate :page => params[:page]
  end
  
  def project_mass_update
    params[:project].keys.each do |id|
      logger.info(id)
      project = Project.find_by_id(id)
      if project
        project.update_attributes params[:project][id]
      end
    end
    
    redirect_to :action => :project_list, :page => params[:page].blank? ? 1 : params[:page]
  end
  
  def change_state
    project = Project.find_by_id(params[:id])
    if project
      if params[:state] == 'hide'
        project.hide!
      elsif params[:state] == 'show'
        project.show!
      elsif params[:state] == 'accept'
        project.accept!
      elsif params[:state] == 'reject'
        project.reject!
      end
    end
    
    redirect_to :action => :project_list, :page => params[:page].blank? ? 1 : params[:page]
  end
  
end
