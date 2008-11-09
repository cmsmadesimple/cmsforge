class ProjectController < ApplicationController

  before_filter :login_required, :only => [ :register, :admin, :demote, :promote, :remove_from_project, :update_package, :show_pending, :add_to_project, :add_comment ]

  def list_tagged
    @projects = Project.find_tagged_with(params[:id])
    render :template => "project/list" 
  end
  
  def list
    respond_to do |format|
      format.xml { render :xml => Project.find_in_state('accepted', :all, :order => 'id ASC').to_xml }
    end
  end

  def view
    @project = Project.find_by_unix_name_and_state(params[:unix_name], 'accepted') || Project.find_by_id_and_state(params[:id], 'accepted')
    respond_to do |format|
      format.html
      format.xml { render :xml => @project.to_xml(:include => {:packages => {:include => [:releases]}}) }
    end
  end
  
  def code
    @project = Project.find_by_unix_name_and_state(params[:unix_name], 'accepted') || Project.find_by_id_and_state(params[:id], 'accepted')
    respond_to do |format|
      format.html
      format.xml { render :xml => @project.to_xml }
    end
  end

  def changelog
    @project = Project.find_by_unix_name_and_state(params[:unix_name], 'accepted') || Project.find_by_id_and_state(params[:id], 'accepted')
    respond_to do |format|
      format.html
    end
  end

  def roadmap
    @project = Project.find_by_unix_name_and_state(params[:unix_name], 'accepted') || Project.find_by_id_and_state(params[:id], 'accepted')
    respond_to do |format|
      format.html
    end
  end

  def files
    @project = Project.find_by_unix_name_and_state(params[:unix_name], 'accepted') || Project.find_by_id_and_state(params[:id], 'accepted')
    respond_to do |format|
      format.html
      format.xml { render :xml => @project.to_xml }
    end
  end

  def show_pending
    @project = Project.find_by_id_and_state(params[:id], 'pending')
    if current_user.superuser and @project.pending?
      respond_to do |format|
        format.html
      end
    else
      redirect_to current_user.home_url
    end
  end
  
  def approve
    @project = Project.find_by_id(params[:project_id])
    if current_user.superuser and @project.pending?
      if params[:status] == 'true'
        @project.accept!
        flash[:notice] = 'Project Approved'
      else
        @project.reject_reason = params[:reject_reason]
        @project.save
        @project.reject!
        flash[:notice] = 'Project Rejected'
      end
    end
    redirect_to current_user.home_url
  end

  def register
    unless params[:cancel].nil?
      redirect_to :action => 'view', :controller => 'account'
      return
    end
    unless params[:project].nil? or current_user.nil?
      @project = Project.new(params[:project])
      unless @project.valid?
        render :action => 'register'
      else
        @project.tag_list = (params[:tag_list]);
        @project.save
        assign = Assignment.new
        assign.user_id = current_user.id
        assign.project_id = @project.id
        assign.role = 'Administrator'
        assign.save
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
      @project.tag_list = params[:tag_list]
      if @project.valid?
        @project.save
        flash[:notice] = 'Project Updated'
      end
    end
  end

  def demote
    assign = Assignment.find_by_id(params[:id])
    unless assign.nil?

      @project = Project.find_by_id(assign.project_id)

      unless logged_in? and current_user.admin_of?(@project)
        redirect_to :action => 'view', :id => @project.id and return
      end

      assign.role = 'Member'
      assign.save
      flash[:notice] = 'User Demoted to Member'

      redirect_to :action => 'admin', :id => assign.project_id
    else
      flash[:notice] = 'There was an error demoting the user'
    end

  end
  
  def search
    @projects = Project.find_with_ferret(params['id'])
    if @projects.size == 1
      redirect_to @projects[0].home_page
    end
  end

  def promote
    assign = Assignment.find_by_id(params[:id])
    unless assign.nil?

      @project = Project.find_by_id(assign.project_id)

      unless logged_in? and current_user.admin_of?(@project)
        redirect_to :action => 'view', :id => @project.id and return
      end

      assign.role = 'Administrator'
      assign.save
      flash[:notice] = 'User Promoted to Administrator'

      redirect_to :action => 'admin', :id => assign.project_id
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
      assign.project_id = params[:id]
      assign.role = 'Member'
      assign.save
      flash[:notice] = 'User Added to Project'
    else
      flash[:notice] = 'User could not be found'
    end
    redirect_to :action => 'admin', :id => params[:id]

  end

  def remove_from_project
    @project = nil
    assignment = Assignment.find_by_id(params[:id])
    unless assignment.nil?
      @project = Project.find_by_id(assignment.project_id)
      unless logged_in? and current_user.admin_of?(@project)
        redirect_to :action => 'view', :id => params[:id] and return
      end
      Assignment.delete(assignment)
      flash[:notice] = 'User Removed from Project'
    else
      redirect_to '/'
    end

    redirect_to :action => 'admin', :id => assignment.project_id
  end

  def update_package
    @project = Project.find_by_id(params[:project_id])
    unless @project.nil? or !current_user.admin_of?(@project)
      package = Package.find_by_id(params[:id])
      unless package.nil?
        package.update_attributes(params[:package])
        if package.valid? and package.save
          flash[:notice] = 'Package Updated'
        else
          flash[:warning] = 'There was an error updating the package'
        end
      else
        flash[:warning] = 'There was an error updating the package'
      end
    end

    redirect_to :action => 'admin', :id => params[:project_id]
  end
  
  def add_package_to_project
    @project = Project.find_by_id(params[:id])
    unless logged_in? and current_user.admin_of?(@project)
      redirect_to :action => 'view', :id => params[:id] and return
    end

    package = Package.new
    package.project_id = params[:id]
    package.is_active = true
    package.name = params[:name]
    if package.save
      flash[:notice] = 'Package Added to Project'
    else
      flash[:warning] = 'There was an error adding the Package'
    end

    redirect_to :action => 'admin', :id => params[:id]

  end
  
  def update_bug_version
    @project = Project.find_by_id(params[:project_id])
    unless @project.nil? or !current_user.admin_of?(@project)
      version = BugVersion.find_by_id(params[:id])
      unless version.nil?
        if version.update_attributes(params[:version])
          flash[:notice] = 'Bug Version Updated'
        else
          flash[:warning] = 'There was an error updating the bug version'
        end
      else
        flash[:warning] = 'There was an error updating the bug version'
      end
    end

    redirect_to :action => 'admin', :id => params[:project_id]
  end
  
  def add_bug_version_to_project
    @project = Project.find_by_id(params[:id])
    unless logged_in? and current_user.admin_of?(@project)
      redirect_to :action => 'view', :id => params[:id] and return
    end

    version = BugVersion.new
    version.project_id = params[:id]
    version.name = params[:name]
    if version.save
      flash[:notice] = 'Bug Version Added to Project'
    else
      flash[:warning] = 'There was an error adding the Bug Version'
    end

    redirect_to :action => 'admin', :id => params[:id]

  end

  def add_comment
    @project = Project.find_by_id(params[:project_id])

    unless current_user.nil?
      comment = Comment.new
      comment.comment = params[:add_comment]
      comment.user = current_user
      @project.comments << comment
    end

    redirect_to :action => 'view', :id => @project.id
  end

end
