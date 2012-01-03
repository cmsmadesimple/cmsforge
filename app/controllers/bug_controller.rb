class BugController < ApplicationController
  
  before_filter :login_required, :only => [ :add_comment, :add, :update ]
  
  def list
    @show_closed = (params[:show_closed] == 'true' || params[:show_closed] == '1')
    conditions = @show_closed ? ['1 = 1'] : ['state = ?', 'Open']
    @so = 'id ASC'
    @so = params[:sort_by] unless (params[:sort_by].nil?)
    params[:page] ||= 1
    if params[:page].to_i < 1
      params[:page] = 1
    end
    @bugs = Bug.paginate_by_project_id(params[:id], :order => @so, :conditions => conditions, :page => params[:page])
    @project = Project.find_by_id_and_state(params[:id], 'accepted')
    @project_id = params[:id]
    respond_to do |format|
      format.html { render }
      format.js { render :template => "bug/list.js.rjs" }
      format.xml { render :xml => @bugs.to_xml }
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
    @project = Project.find_by_id_and_state(params[:id], 'accepted')
  
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
