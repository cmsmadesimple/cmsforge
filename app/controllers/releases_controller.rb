class ReleasesController < ApplicationController
  
  def index
    @releases = Release.find(:all, :conditions => ['package_id = ?', params[:package_id]], :order => 'id DESC')
    @package = Package.find_by_id(params[:package_id])
    @project = @package.project
  end
  
  def new
    @release = Release.new
    @release.package_id = params[:package_id]
    @project = @release.package.project
  end
  
  def create 
    @release = Release.new(params[:release]) 
    @release.released_by = current_user.id
    @project = @release.package.project
    if @release.save 
      flash[:notice] = 'Release was successfully created.' 
      redirect_to :action => 'edit', :id => @release.id
    else 
      render :action => 'new' 
    end 
  end
  
  def edit
    @release = Release.find_by_id(params[:id])
    @project = @release.package.project
  end
  
  def update 
    @release = Release.find(params[:release][:id])
    @project = @release.package.project
    if @release.update_attributes(params[:release]) 
      flash[:notice] = 'Release was successfully updated.' 
      redirect_to :action => 'index', :package_id => @release.package
    else 
      render :action => 'edit' 
    end 
  end
  
  def add_file
    @release = Release.find(params[:release_id])
    unless @release.nil? or !current_user.member_of?(@release.package.project)
      file = ReleasedFile.new
      file.release_id = @release.id
      file.uploaded_data = params[:uploaded_data]
      file.downloads = 0
      file.save
    end
    redirect_to :action => 'edit', :id => @release.id
  end
  
  def delete_file
    @release_file = ReleasedFile.find(params[:id])
    unless @release_file.nil? or !current_user.member_of?(@release_file.release.package.project)
      ReleasedFile.destroy(@release_file.id)
    end
    redirect_to :action => 'edit', :id => @release_file.release.id
  end
  
end
