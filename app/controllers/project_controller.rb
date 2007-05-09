class ProjectController < ApplicationController
  
  def view
    @project = Project.find_by_unix_name(params[:unix_name])
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
  
end
