class BugController < ApplicationController
  
  before_filter :authenticate_user!, :only => [ :add_comment, :add, :update ]
  
  def list
    @show_closed ||= false
    @show_closed = (params[:show_closed] == 'true' || params[:show_closed] == '1') if params[:show_closed]
    @conditions = @show_closed ? {} : {:state => 'Open'}
    params[:sort_by] ||= 'id ASC'
    params[:page] ||= 1

    @project_id = params[:id]
    @project = Project.find_by_id_and_state(@project_id, 'accepted')

    respond_to do |format|
      format.html do
        @bugs = @project.bugs.where(@conditions).paginate(:page => params[:page]).order(params[:sort_by])
        if request.xhr?
          render :partial => 'bug_list', :layout => false
        else
          render
        end
      end
      format.xml do
        @bugs = @project.bugs.where(@conditions).order(params[:sort_by])
        render :xml => @bugs
      end
      format.json do
        @bugs = @project.bugs.where(@conditions).order(params[:sort_by])
        render :json => @bugs
      end
    end
  end
  
  def view
    @bug = Bug.find_by_id(params[:id])
    unless @bug.nil?
      @project = @bug.project
    end
    respond_to do |format|
      format.html { render }
      format.xml { render :xml => @bug.to_xml }
    end
  end
  
  def update
    @bug = Bug.find_by_id(params[:bug][:id])
    @project = @bug.project
    @bug.attributes = params[:bug]
    if @bug.valid?
      unless params[:add_comment].blank?
        comment = Comment.new
        comment.comment = params[:add_comment]
        comment.user = current_user
        @bug.comments << comment
      end
      @bug.save
      flash.now[:notice] = "Bug Succesfully Updated"
    end

    render :action => 'view' 
  end
  
  def add_comment
    bug = Bug.find_by_id(params[:bug_id])
    unless params[:add_comment].blank?
      comment = Comment.new
      comment.comment = params[:add_comment]
      comment.user = current_user
      bug.comments << comment
  
      #Kick off an update email
      bug.save
    end
    
    redirect_to :action => 'view', :id => bug.id
  end
  
  def add
    @bug = Bug.new(params[:bug])
    @bug.created_by = current_user
    @bug.project_id = params[:id] unless params[:id].nil?
  
    unless params[:cancel].nil?
      redirect_to :action => 'list', :id => @bug.project_id
      return
    end
  
    unless params[:bug].nil?
      if @bug.valid?
        @bug.state = 'Open'
        @bug.save
        redirect_to :action => 'list', :id => @bug.project_id
        return
      end
    end
  end
  
end
