class ActivitiesController < ApplicationController
  include ActivitiesHelper
  
  before_action :set_activity, only: [:change, :undo_delete, :approve_delete, :show, :edit, :update, :destroy]

  # GET /activities
  # GET /activities.json
  def index
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = nil
      @to_date =  DateTime.now
    end
  end

  # GET /activities/1
  # GET /activities/1.json
  def show
  end

  # GET /activities/new
  def new
    @activity = Activity.new
  end

  # GET /activities/1/edit
  def edit
  end

  # POST /activities
  # POST /activities.json
  def create
    @activity = Activity.new(activity_params)
    @activity.account_manager = @activity.contact.account_manager
    @activity.user = current_user

    respond_to do |format|
      if @activity.save
        format.html { redirect_to @activity, notice: 'Activity was successfully created.' }
        format.json { render action: 'show', status: :created, location: @activity }
      else
        format.html { render action: 'new' }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /activities/1
  # PATCH/PUT /activities/1.json
  def update
    respond_to do |format|
      if @activity.update(activity_params)
        format.html { redirect_to @activity, notice: 'Activity was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.json
  def destroy
    @activity.delete
    
    render nothing: true
    #respond_to do |format|
    #  format.html { redirect_to activities_url }
    #  format.json { head :no_content }
    #end
  end
  
  def datatable
    result = Activity.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_activity_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def approve_delete
    authorize! :approve_delete, @activity
    
    @activity.update_attribute(:deleted, 2)
    
    respond_to do |format|
      format.html { render "/activities/deleted", layout: nil }
      format.json { render action: 'show', status: :created, location: @activity }
    end
  end
  
  def approve_all
    authorize! :approve_all, Activity
    
    if params[:ids].present?
      if !params[:check_all_page].nil?
        params[:intake_year] = params["filter"]["intake(1i)"] if params["filter"].present?
        params[:intake_month] = params["filter"]["intake(2i)"] if params["filter"].present?
        
        if params[:is_individual] == "false"
          params[:contact_types] = nil
        end        
        
        @contacts = Activity.filters(params, current_user)
      else
        @contacts = Activity.where(id: params[:ids])
      end
    end
    
    @contacts.each do |c|
      c.update_attribute(:deleted, 2) if current_user.can?(:approve_delete, c)
    end
    
    respond_to do |format|
      format.html { render text: "Note logs were approved!" }
      format.json { render action: 'show', status: :created, location: @course_register }
    end
  end
  
  def undo_delete
    authorize! :undo_delete, @activity
    
    @activity.update_attribute(:deleted, 0)
    
    respond_to do |format|
      format.html { render "/activities/undo_delete", layout: nil }
      format.json { render action: 'show', status: :created, location: @activity }
    end
  end
  
  def change
    new_a = @activity.dup
    @activity.update_attribute(:deleted, 2)
    new_a.note = params[:text]
    new_a.save
    
    render text: "Activity was successfully changed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activity
      @activity = Activity.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def activity_params
      params.require(:activity).permit(:user_id, :contact_id, :note)
    end
end
