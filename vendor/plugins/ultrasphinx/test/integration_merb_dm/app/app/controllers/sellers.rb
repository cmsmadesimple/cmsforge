class Sellers < Application
  # provides :xml, :yaml, :js

  def index
    @sellers = Seller.all
    display @sellers
  end

  def show
    @seller = Seller.get(params[:id])
    raise NotFound unless @seller
    display @seller
  end

  def new
    only_provides :html
    @seller = Seller.new
    render
  end

  def edit
    only_provides :html
    @seller = Seller.get(params[:id])
    raise NotFound unless @seller
    render
  end

  def create
    @seller = Seller.new(params[:seller])
    if @seller.save
      redirect url(:seller, @seller)
    else
      render :new
    end
  end

  def update
    @seller = Seller.get(params[:id])
    raise NotFound unless @seller
    if @seller.update_attributes(params[:seller]) || !@seller.dirty?
      redirect url(:seller, @seller)
    else
      raise BadRequest
    end
  end

  def destroy
    @seller = Seller.get(params[:id])
    raise NotFound unless @seller
    if @seller.destroy
      redirect url(:seller)
    else
      raise BadRequest
    end
  end

end
