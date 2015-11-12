class StockTypesController < ApplicationController
  include StockTypesHelper
  load_and_authorize_resource
  
  before_action :set_stock_type, only: [:delete, :show, :edit, :update, :destroy]

  # GET /stock_types
  # GET /stock_types.json
  def index
    @stock_types = StockType.all
    
    respond_to do |format|
      format.html { render layout: "content" if params[:tab_page].present? }
      format.json {
        render json: StockType.full_text_search(params[:q])
      }
    end
  end

  # GET /stock_types/1
  # GET /stock_types/1.json
  def show
  end

  # GET /stock_types/new
  def new
    @stock_type = StockType.new
  end

  # GET /stock_types/1/edit
  def edit
  end

  # POST /stock_types
  # POST /stock_types.json
  def create
    @stock_type = StockType.new(stock_type_params)
    @stock_type.user = current_user

    respond_to do |format|
      if @stock_type.save
        @stock_type.update_status("create", current_user)        
        @stock_type.save_draft(current_user)
        
        format.html { redirect_to "/home/close_tab", notice: 'Stock type was successfully created.' }
        format.json { render action: 'show', status: :created, location: @stock_type }
      else
        format.html { render action: 'new' }
        format.json { render json: @stock_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stock_types/1
  # PATCH/PUT /stock_types/1.json
  def update
    respond_to do |format|
      if @stock_type.update(stock_type_params)
        @stock_type.update_status("update", current_user)        
        @stock_type.save_draft(current_user)
        
        format.html { redirect_to "/home/close_tab", notice: 'Stock type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @stock_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_types/1
  # DELETE /stock_types/1.json
  def destroy
    @stock_type.destroy
    respond_to do |format|
      format.html { redirect_to stock_types_url }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = StockType.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_stock_type_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  ########## BEGIN REVISION ###############
  
  def approve_new
    authorize! :approve_new, @stock_type
    
    @stock_type.approve_new(current_user)
    
    respond_to do |format|
      format.html { render "/stock_types/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @stock_type }
    end
  end
  
  def approve_update
    authorize! :approve_update, @stock_type
    
    @stock_type.approve_update(current_user)
    
    respond_to do |format|
      format.html { render "/stock_types/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @stock_type }
    end
  end
  
  def approve_delete
    authorize! :approve_delete, @stock_type
    
    @stock_type.approve_delete(current_user)
    
    respond_to do |format|
      format.html { render "/stock_types/deleted", layout: nil }
      format.json { render action: 'show', status: :created, location: @stock_type }
    end
  end
  
  def undo_delete
    authorize! :undo_delete, @stock_type
    
    @stock_type.undo_delete(current_user)
    
    respond_to do |format|
      format.html { render "/stock_types/undo_delete", layout: nil }
      format.json { render action: 'show', status: :created, location: @stock_type }
    end
  end
  
  def approved
    render layout: "content"
  end
  
  def field_history
    @drafts = @stock_type.field_history(params[:type])
    
    render layout: nil
  end

  def delete
    
    respond_to do |format|
      if @stock_type.delete
        @stock_type.save_draft(current_user)
        
        format.html { render "/stock_types/deleted", layout: nil }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @stock_type.errors, status: :unprocessable_entity }
      end
    end
  end
  
  ########## BEGIN REVISION ###############
  
  def approve_all
    if params[:ids].present?
      if !params[:check_all_page].nil?
        @items = StockType.filter(params, current_user)
      else
        @items = StockType.where(id: params[:ids])
      end
    end
    
    @items.each do |c|
      c.approve_delete(current_user) if current_user.can?(:approve_delete, c)
      c.approve_new(current_user) if current_user.can?(:approve_new, c)
      c.approve_update(current_user) if current_user.can?(:approve_update, c)
    end
    
    respond_to do |format|
      format.html { render "/stock_types/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @course_type }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock_type
      @stock_type = StockType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_type_params
      params.require(:stock_type).permit(:name, :description, :user_id, :annoucing_user_ids, :parent_id, :status)
    end
end
