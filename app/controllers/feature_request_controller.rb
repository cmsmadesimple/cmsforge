class FeatureRequestController < ApplicationController
  
  before_filter :authenticate_user!, :only => [ :add_comment, :add, :update ]
  
  def list
    @show_closed = (params[:show_closed] == 'true' || params[:show_closed] == '1')
    @conditions = @show_closed ? {} : {:state => 'Open'}
    params[:sort_by] ||= 'id ASC'

    @project_id = params[:id]
    @project = Project.find_by_id_and_state(@project_id, 'accepted')
    @feature_requests = @project.feature_requests.where(@conditions).paginate(:page => params[:page]).order(params[:sort_by])

    respond_to do |format|
      format.html { render }
      format.js { render :template => "feature_request/list.js.rjs" }
      format.xml { render :xml => @feature_requests.to_xml }
    end
  end
  
  def view
    @feature_request = FeatureRequest.find_by_id(params[:id])
    unless @feature_request.nil?
      @project = @feature_request.project
    end
    respond_to do |format|
      format.html { render }
      format.xml { render :xml => @feature_request.to_xml }
    end
  end
  
  def update
    @feature_request = FeatureRequest.find_by_id(params[:feature_request][:id])
    @project = @feature_request.project
    @feature_request.attributes = params[:feature_request]
    if @feature_request.valid?
      unless params[:add_comment].blank?
        comment = Comment.new
        comment.comment = params[:add_comment]
        comment.user = current_user
        @feature_request.comments << comment
      end
      @feature_request.save
      flash.now[:notice] = "Feature Request Succesfully Updated"
    end
    
    render :action => 'view'
  end
  
  def add_comment
    feature_request = FeatureRequest.find_by_id(params[:feature_request_id])
    unless params[:add_comment].blank?
      comment = Comment.new
      comment.comment = params[:add_comment]
      comment.user = current_user
      feature_request.comments << comment
    
      #Kick off update email
      feature_request.save
    end
    
    redirect_to :action => 'view', :id => feature_request.id
  end
  
  def add
    @feature_request = FeatureRequest.new(params[:feature_request])
    @feature_request.created_by = current_user
    @feature_request.project_id = params[:id] unless params[:id].nil?
  
    unless params[:cancel].nil?
      redirect_to :action => 'list', :id => @feature_request.project_id
      return
    end
  
    unless params[:feature_request].nil?
      if @feature_request.valid?
        @feature_request.state = 'Open'
        @feature_request.save
        redirect_to :action => 'list', :id => @feature_request.project_id
        return
      end
    end
  end
  
end
