class StockUpdatesController < ApplicationController
  load_and_authorize_resource
  
  before_action :set_stock_update, only: [:show, :edit, :update, :destroy]

  # GET /stock_updates
  # GET /stock_updates.json
  def index
    @stock_updates = StockUpdate.all
  end

  # GET /stock_updates/1
  # GET /stock_updates/1.json
  def show
  end

  # GET /stock_updates/new
  def new
    @stock_update = StockUpdate.new
    @stock_update.book = Book.find(params[:book_id])
  end

  # GET /stock_updates/1/edit
  def edit
  end

  # POST /stock_updates
  # POST /stock_updates.json
  def create
    @stock_update = StockUpdate.new(stock_update_params)
    @stock_update.user = current_user

    respond_to do |format|
      if @stock_update.save
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @stock_update, notice: 'Stock update was successfully created.' }
        format.json { render action: 'show', status: :created, location: @stock_update }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @stock_update.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stock_updates/1
  # PATCH/PUT /stock_updates/1.json
  def update
    respond_to do |format|
      if @stock_update.update(stock_update_params)
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @stock_update, notice: 'Stock update was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @stock_update.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_updates/1
  # DELETE /stock_updates/1.json
  def destroy
    @stock_update.destroy
    respond_to do |format|
      format.html { redirect_to stock_updates_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock_update
      @stock_update = StockUpdate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_update_params
      params.require(:stock_update).permit(:type_name, :book_id, :quantity, :created_date, :user_id)
    end
end
