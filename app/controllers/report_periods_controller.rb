class ReportPeriodsController < ApplicationController
  include ReportPeriodsHelper
  load_and_authorize_resource
  
  before_action :set_report_period, only: [:undo_delete, :delete, :show, :edit, :update, :destroy]

  # GET /report_periods
  # GET /report_periods.json
  def index
    respond_to do |format|
      format.html { render layout: "content" if params[:tab_page].present? }
      format.json {
        render json: ReportPeriod.full_text_search(params)
      }
    end
  end

  # GET /report_periods/1
  # GET /report_periods/1.json
  def show
  end

  # GET /report_periods/new
  def new
    @report_period = ReportPeriod.new
  end

  # GET /report_periods/1/edit
  def edit
  end

  # POST /report_periods
  # POST /report_periods.json
  def create
    @report_period = ReportPeriod.new(report_period_params)
    @report_period.status = "active"
    @report_period.user_id = current_user.id
    
    respond_to do |format|
      if @report_period.save        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @course, notice: 'Report period was successfully created.' }
        format.json { render action: 'show', status: :created, location: @report_period }
      else
        format.html { render action: 'new' }
        format.json { render json: @report_period.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /report_periods/1
  # PATCH/PUT /report_periods/1.json
  def update
    respond_to do |format|
      if @report_period.update(report_period_params)
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @course, notice: 'Report period was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @report_period.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /report_periods/1
  # DELETE /report_periods/1.json
  def destroy
    @report_period.destroy
    respond_to do |format|
      format.html { redirect_to report_periods_url }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = ReportPeriod.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_course_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def delete
    @report_period.status = "deleted"
    @report_period.save
    
    respond_to do |format|
      format.html { render text: "Report period was successfully deleted." }
      format.json { render action: 'show', status: :created, location: @phrase }
    end
  end
  
  def undo_delete
    @report_period.status = "active"
    @report_period.save
    
    respond_to do |format|
      format.html { render text: "Report period was successfully restored." }
      format.json { render action: 'show', status: :created, location: @phrase }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report_period
      @report_period = ReportPeriod.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_period_params
      params.require(:report_period).permit(:user_id, :name, :start_at, :end_at, :status)
    end
end
