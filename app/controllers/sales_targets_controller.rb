class SalesTargetsController < ApplicationController
  include SalesTargetsHelper
  load_and_authorize_resource
  
  before_action :set_sales_target, only: [:undo_delete, :delete, :show, :edit, :update, :destroy]

  # GET /sales_targets
  # GET /sales_targets.json
  def index
    @sales_targets = SalesTarget.all
  end

  # GET /sales_targets/1
  # GET /sales_targets/1.json
  def show
  end

  # GET /sales_targets/new
  def new
    @sales_target = SalesTarget.new
  end

  # GET /sales_targets/1/edit
  def edit
  end

  # POST /sales_targets
  # POST /sales_targets.json
  def create
    
    
    respond_to do |format|
      if true        
        params[:staff_ids].split(",").each do |sid|
          @sales_target = SalesTarget.new(sales_target_params)
          @sales_target.status = "active"
          @sales_target.staff_id = sid
          @sales_target.save
        end
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @course, notice: 'Sales target was successfully created.' }
        format.json { render action: 'show', status: :created, location: @sales_target }
      else
        format.html { render action: 'new' }
        format.json { render json: @sales_target.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sales_targets/1
  # PATCH/PUT /sales_targets/1.json
  def update
    respond_to do |format|
      if @sales_target.update(sales_target_params)
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @course, notice: 'Sales target was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @sales_target.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sales_targets/1
  # DELETE /sales_targets/1.json
  def destroy
    @sales_target.destroy
    respond_to do |format|
      format.html { redirect_to sales_targets_url }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = SalesTarget.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_course_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def delete
    @sales_target.status = "deleted"
    @sales_target.save
    
    respond_to do |format|
      format.html { render text: "Sales target was successfully deleted." }
      format.json { render action: 'show', status: :created, location: @phrase }
    end
  end
  
  def undo_delete
    @sales_target.status = "active"
    @sales_target.save
    
    respond_to do |format|
      format.html { render text: "Sales target was successfully restored." }
      format.json { render action: 'show', status: :created, location: @phrase }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sales_target
      @sales_target = SalesTarget.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sales_target_params
      params.require(:sales_target).permit(:staff_id, :report_period_id, :user_id, :amount)
    end
end
