class SeminarsController < ApplicationController
  include SeminarsHelper
  load_and_authorize_resource
  
  before_action :set_seminar, only: [:show, :edit, :update, :destroy]

  # GET /seminars
  # GET /seminars.json
  def index
    @seminars = Seminar.all
    
    respond_to do |format|
      format.html
      format.json {
        render json: Seminar.full_text_search(params)
      }
    end
  end

  # GET /seminars/1
  # GET /seminars/1.json
  def show
  end

  # GET /seminars/new
  def new
    @seminar = Seminar.new
    @start_date = ""
    @start_time = ""
  end

  # GET /seminars/1/edit
  def edit
    @types = []
    @individual_statuses = ["true"]
    
    @start_date = @seminar.start_at.strftime("%d-%b-%Y")
    @start_time = @seminar.start_at.strftime("%I:%M %p")
  end

  # POST /seminars
  # POST /seminars.json
  def create
    @seminar = Seminar.new(seminar_params)
    @seminar.user = current_user
    
    if params[:start_date].present? && params[:start_time].present?
      @seminar.start_at = params[:start_date]+" "+params[:start_time]
    end

    respond_to do |format|
      if @seminar.save
        format.html { redirect_to @seminar, notice: 'Seminar was successfully created.' }
        format.json { render action: 'show', status: :created, location: @seminar }
      else
        format.html { render action: 'new' }
        format.json { render json: @seminar.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /seminars/1
  # PATCH/PUT /seminars/1.json
  def update
    @seminar.assign_attributes(seminar_params)
    if params[:start_date].present? && params[:start_time].present?
      @seminar.start_at = params[:start_date]+" "+params[:start_time]
    end
    respond_to do |format|
      if @seminar.save
        format.html { redirect_to @seminar, notice: 'Seminar was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @seminar.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /seminars/1
  # DELETE /seminars/1.json
  def destroy
    @seminar.destroy
    respond_to do |format|
      format.html { redirect_to seminars_url }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = Seminar.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_seminar_actions(item)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def add_contacts
    @seminar.add_contacts(params[:contact_ids].split(","))
    
    render nothing: true
  end
  
  def remove_contacts
    @seminar.remove_contacts(params[:contact_ids].split(","))
    
    render nothing: true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_seminar
      @seminar = Seminar.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def seminar_params
      params.require(:seminar).permit(:name, :description, :start_at)
    end
end
