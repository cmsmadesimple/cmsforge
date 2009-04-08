class States < Application
  # provides :xml, :yaml, :js

  def index
    @states = State.all
    display @states
  end

  def show
    @state = State.get(params[:id])
    raise NotFound unless @state
    display @state
  end

  def new
    only_provides :html
    @state = State.new
    render
  end

  def edit
    only_provides :html
    @state = State.get(params[:id])
    raise NotFound unless @state
    render
  end

  def create
    @state = State.new(params[:state])
    if @state.save
      redirect url(:state, @state)
    else
      render :new
    end
  end

  def update
    @state = State.get(params[:id])
    raise NotFound unless @state
    if @state.update_attributes(params[:state]) || !@state.dirty?
      redirect url(:state, @state)
    else
      raise BadRequest
    end
  end

  def destroy
    @state = State.get(params[:id])
    raise NotFound unless @state
    if @state.destroy
      redirect url(:state)
    else
      raise BadRequest
    end
  end

end
