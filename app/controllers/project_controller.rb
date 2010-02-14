class ProjectController < ApplicationController

  before_filter :login_required, :only => [ :register, :admin, :demote, :promote, :remove_from_project, :update_package, :show_pending, :add_to_project, :add_comment ]
  before_filter :check_format
  layout 'application', :except => [:changelog, :release_notes]
  
  def check_format
    unless ['js', 'javascript', 'html', 'rss', 'xml'].include? params[:format]
      params[:format] = 'html'
    end
  end

  def list_tagged
    if params[:id].nil?
      params[:id] = ''
    end
    @projects = Project.find_tagged_with(params[:id])
  end
  
  def list
    conditions = ['state = ?', 'accepted']
    if params[:project_type]
      conditions[0] = conditions[0] + " and project_type = ?"
      conditions << params[:project_type]
    end
    if params[:page].to_i < 1
      params[:page] = 1
    end
    respond_to do |format|
      format.html { @projects = Project.paginate(:page => params[:page], :order => 'name ASC', :conditions => conditions) }
      format.xml { render :xml => Project.find_in_state(:all, :accepted, :order => 'id ASC').to_xml }
    end
  end
  
  def list_xml_files
    @files = ReleasedFile.find(:all, :conditions => "filename LIKE '%xml'", :order => 'filename ASC')
    respond_to do |format|
      format.html { render :xml => @files.to_xml(:methods => [:public_filename]) }
      format.xml { render :xml => @files.to_xml(:methods => [:public_filename]) }
    end
  end

  def view
    @project = Project.find_by_unix_name_and_state(params[:unix_name], 'accepted') || Project.find_by_id_and_state(params[:id], 'accepted')
    @feed_url = url_for(:action => @project.unix_name + '.rss', :controller => 'projects', :only_path => false)
    respond_to do |format|
      format.html {
        render :template => 'project/view.rhtml'
      }
      format.xml { render :xml => @project.to_xml(:include => {:packages => {:include => [:releases]}}) }
      format.rss {
        @releases = Release.find_by_sql("select releases.* from releases inner join packages on packages.id = releases.package_id where packages.project_id = " + @project.id.to_s + " order by created_at desc limit 25")
        render :template => 'project/view.rxml', :layout => false
      }
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
  
  def changelog
    @release = Release.find_by_id(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  def release_notes
    @release = Release.find_by_id(params[:id])
    respond_to do |format|
      format.html
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
    
    @admin_count = 0
    @project.assignments.each do |assignment|
      if assignment.role == 'Administrator'
        @admin_count = @admin_count + 1
      end
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
    term = !params['id'].nil? ? params['id'] : ''
    #@projects = Project.find_with_ferret(term)
    @search = Ultrasphinx::Search.new(:query => term, :class_names => ['Project'])
    @search.excerpt
    @projects = @search.results
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

    unless current_user.nil? or params[:add_comment].blank?
      comment = Comment.new
      comment.comment = params[:add_comment]
      comment.user = current_user
      @project.comments << comment
    end

    redirect_to :action => 'view', :id => @project.id
  end
  
  def join_request
    unless params[:id].nil?
      project = Project.find(params[:id])
      unless current_user == :false or project.users.include?(current_user) or project.has_join_request(current_user)
        request = ProjectJoinRequest.new
        request.user_id = current_user.id
        request.project_id = project.id
        request.state = 'pending'
        if request.save
          flash[:notice] = 'The project administrators have been notified of your request.  You will be contacted soon.'
        else
          flash[:warning] = 'There was an error sending your request.  Please contact a project\'s administrator to join.'
        end
      end
    end
    redirect_to :action => 'view', :id => project.id
  end
  
  def accept_request
    if params[:id].nil?
      redirect_to '/'
    end
    req = ProjectJoinRequest.find(params[:id])
    if req.nil?
      redirect_to '/'
    end
    unless current_user == :false or !current_user.admin_of?(req.project)
      req.accept!
    end
    redirect_to :action => 'view', :id => req.project.id
  end
  
  def reject_request
    if params[:id].nil?
      redirect_to '/'
    end
    req = ProjectJoinRequest.find(params[:id])
    if req.nil?
      redirect_to '/'
    end
    unless current_user == :false or !current_user.admin_of?(req.project)
      req.reject!
    end
    redirect_to :action => 'view', :id => req.project.id
  end
  
  def latest_files
    @feed_url = url_for(:action => 'latest_files.rss', :controller => 'project', :only_path => false)
    if params[:page].to_i < 1
      params[:page] = 1
    end
    respond_to do |format|
      format.html { @releases = Release.paginate(:page => params[:page], :order => 'created_at DESC') }
      format.rss {
        @releases = Release.find(:all, :order => 'created_at DESC', :limit => 25)
        render :layout => false
      }
      #format.xml { render :xml => Project.find_in_state(:all, :accepted, :order => 'id ASC').to_xml }
    end
  end
  
  def latest_registrations
    @feed_url = url_for(:action => 'latest_registrations.rss', :controller => 'project', :only_path => false)
    conditions = ['state = ?', 'accepted']
    if params[:page].to_i < 1
      params[:page] = 1
    end
    respond_to do |format|
      format.html { @projects = Project.paginate(:page => params[:page], :order => 'created_at DESC', :conditions => conditions) }
      format.rss {
        @projects = Project.find(:all, :order => 'created_at DESC', :conditions => conditions, :limit => 25)
        render :layout => false
      }
      #format.xml { render :xml => Project.find_in_state(:all, :accepted, :order => 'id ASC').to_xml }
    end
  end

end
