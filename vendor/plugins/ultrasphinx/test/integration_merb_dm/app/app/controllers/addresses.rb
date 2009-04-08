class Addresses < Application
  # provides :xml, :yaml, :js

  def index
    @addresses = Address.all
    display @addresses
  end

  def show
    @address = Address.get(params[:id])
    raise NotFound unless @address
    display @address
  end

  def new
    only_provides :html
    @address = Address.new
    render
  end

  def edit
    only_provides :html
    @address = Address.get(params[:id])
    raise NotFound unless @address
    render
  end

  def create
    @address = Address.new(params[:address])
    if @address.save
      redirect url(:address, @address)
    else
      render :new
    end
  end

  def update
    @address = Address.get(params[:id])
    raise NotFound unless @address
    if @address.update_attributes(params[:address]) || !@address.dirty?
      redirect url(:address, @address)
    else
      raise BadRequest
    end
  end

  def destroy
    @address = Address.get(params[:id])
    raise NotFound unless @address
    if @address.destroy
      redirect url(:address)
    else
      raise BadRequest
    end
  end

end
