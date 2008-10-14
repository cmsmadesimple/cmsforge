class BugController < ApplicationController
  
  before_filter :login_required, :only => [ :add_comment, :add, :update ]
  
  def list
    @show_closed = (params[:show_closed] == 'true' || params[:show_closed] == '1')
    conditions = @show_closed ? ['1 = 1'] : ['state = ?', 'Open']
    @so = 'id ASC'
    @so = params[:sort_by] unless (params[:sort_by].nil?)
    params[:page] ||= 1
    @bugs = Bug.paginate_by_project_id(params[:id], :order => @so, :conditions => conditions, :page => params[:page])
    @project = Project.find_by_id(params[:id])
    @project_id = params[:id]
    respond_to do |format|
      format.html { render }
      format.js { render :template => "bug/list.js.rjs" }
      format.xml { render :xml => @bugs.to_xml }
    end
  end
  
  def view
    @bug = Bug.find_by_id(params[:id])
    @project = @bug.project
    respond_to do |format|
      format.html { render }
      format.xml { render :xml => @bug.to_xml }
    end
  end
  
  def update
    @bug = Bug.find_by_id(params[:bug][:id])
    @project = @bug.project
    @bug.update_attributes(params[:bug])
    if @bug.valid?
      if @bug.save
        flash.now[:notice] = "Bug Succesfully Updated"
      end
    end

    render :action => 'view' 
  end
  
  def add_comment
    bug = Bug.find_by_id(params[:bug_id])
  
    comment = Comment.new
    comment.comment = params[:add_comment]
    comment.user = current_user
    bug.comments << comment
    
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
