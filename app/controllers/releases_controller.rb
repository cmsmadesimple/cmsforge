class ReleasesController < ApplicationController
  
  before_filter :login_required, :only => [ :index, :new, :create, :edit, :update, :add_file, :delete_file ]
  
  def index
    @releases = Release.find(:all, :conditions => ['package_id = ?', params[:package_id]], :order => 'id DESC')
    @package = Package.find_by_id(params[:package_id])
    @project = @package.project
  end
  
  def info
    @release = Release.find_by_id(params[:id])
    respond_to do |format|
      format.xml { render :xml => @release.to_xml(:include => [:released_files])}
    end
  end
  
  def new
    @release = Release.new
    @release.package_id = params[:package_id]
    @project = @release.package.project
    if !current_user.member_of?(@release.package.project)
      redirect_to :action => 'view', :id => @project, :controller => 'project'
    end
  end
  
  def create 
    @release = Release.new(params[:release]) 
    @release.released_by = current_user.id
    @project = @release.package.project
    if !current_user.member_of?(@release.package.project)
      redirect_to :action => 'view', :id => @project, :controller => 'project'
    end
    if @release.save
      flash[:notice] = 'Release was successfully created.'
      if params[:add_to_tracker] == '1'
        version = BugVersion.new
        version.project_id = @project.id
        version.name = params[:release][:name]
        version.save
      end
      redirect_to :action => 'edit', :id => @release.id
    else
      render :action => 'new' 
    end
  end
  
  def edit
    @release = Release.find_by_id(params[:id])
    @project = @release.package.project
    if !current_user.member_of?(@release.package.project)
      redirect_to :action => 'view', :id => @project, :controller => 'project'
    end
  end
  
  def update 
    @release = Release.find(params[:release][:id])
    @project = @release.package.project
    if !current_user.member_of?(@release.package.project)
      redirect_to :action => 'view', :id => @project, :controller => 'project'
    end
    if @release.update_attributes(params[:release])
      flash[:notice] = 'Release was successfully updated.'
    end
    render :action => 'edit'
  end
  
  def add_file
    @release = Release.find(params[:release_id])
    unless @release.nil? or !current_user.member_of?(@release.package.project)
      file = ReleasedFile.new
      file.release_id = @release.id
      file.uploaded_data = params[:uploaded_data]
      file.downloads = 0
      if file.save
        flash[:notice] = 'File was successfully added.'
      end
    end
    redirect_to :action => 'edit', :id => @release.id
  end
  
  def delete_file
    @release_file = ReleasedFile.find(params[:id])
    unless @release_file.nil? or !current_user.member_of?(@release_file.release.package.project)
      ReleasedFile.destroy(@release_file.id)
      flash[:notice] = 'File was successfully removed.'
    end
    redirect_to :action => 'edit', :id => @release_file.release.id
  end
  
end
