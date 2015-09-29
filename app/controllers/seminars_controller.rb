class SeminarsController < ApplicationController
  include SeminarsHelper
  load_and_authorize_resource
  
  before_action :set_seminar, only: [:do_import_list, :delete, :check_contact, :import_from_file, :show, :edit, :update, :destroy]

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
    
    @start_date = @seminar.start_at.strftime("%d-%b-%Y") if !@seminar.start_at.nil?
    @start_time = @seminar.start_at.strftime("%I:%M %p") if !@seminar.start_at.nil?
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
        @seminar.update_status("create", current_user)        
        @seminar.save_draft(current_user)
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @seminar, notice: 'Seminar was successfully created.' }
        format.json { render action: 'show', status: :created, location: @seminar }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
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
        @seminar.update_status("update", current_user)        
        @seminar.save_draft(current_user)
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @seminar, notice: 'Seminar was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
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
  
  def student_seminars
    result = Seminar.student_seminars(params, current_user)
    
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
  
  def import_list    
    if params[:file].present?
      @list = @seminar.render_list(params[:file])
      @list = @seminar.process_rendered_list(@list)
    end
  end
  
  def do_import_list
    # save row new data
    params[:rows].each do |row|
      if row[1]["check"].present? && row[1]["check"] == "true"        
        contact = Contact.new(is_individual: true, name: row[1]["name"], email: row[1]["email"], mobile: row[1]["mobile"])
        contact.account_manager = current_user
        contact.save
        
        contact.add_status("new_pending")
        contact.add_status("education_consultant_pending")
        contact.save_draft(User.first)
        
        @seminar.add_contacts([contact])
        contact.set_present_in_seminar(@seminar, row[1]["present"])
      end
    end
    
    # save row new data
    params[:contacts].each do |row|
      if row[1]["check"].present? && row[1]["check"] == "true"  && row[1]["id"].present?
        contact = Contact.find(row[1]["id"])
        @seminar.add_contacts([contact]) if !contact.seminars.include?(@seminar)
        
        contact.set_present_in_seminar(@seminar, row[1]["present"])
      end
    end
    
    respond_to do |format|
      format.html { redirect_to "/home/close_tab" }
      format.json { head :no_content }
    end
  end
  
  def check_contact
    @contact = Contact.find(params[:contact_id])
    @contact.set_present_in_seminar(@seminar, params[:value])    
    
    render layout: nil
  end
  
  ########## BEGIN REVISION ###############
  
  def approve_new
    authorize! :approve_new, @seminar
    
    @seminar.approve_new(current_user)
    
    respond_to do |format|
      format.html { redirect_to params[:tab_page].present? ? "/seminars/approved" : @seminar }
      format.json { render action: 'show', status: :created, location: @seminar }
    end
  end
  
  def approve_update
    authorize! :approve_update, @seminar
    
    @seminar.approve_update(current_user)
    
    respond_to do |format|
      format.html { redirect_to params[:tab_page].present? ? "/seminars/approved" : @seminar }
      format.json { render action: 'show', status: :created, location: @seminar }
    end
  end
  
  def approve_delete
    authorize! :approve_delete, @seminar
    
    @seminar.approve_delete(current_user)
    
    respond_to do |format|
      format.html { redirect_to params[:tab_page].present? ? "/seminars/approved" : @seminar }
      format.json { render action: 'show', status: :created, location: @seminar }
    end
  end
  
  def approved
    render layout: "content"
  end
  
  def field_history
    @drafts = @seminar.field_history(params[:type])
    
    render layout: nil
  end

  def delete
    
    respond_to do |format|
      if @seminar.delete
        @seminar.save_draft(current_user)
        
        format.html { redirect_to "/home/close_tab" }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @seminar.errors, status: :unprocessable_entity }
      end
    end
  end
  
  ########## BEGIN REVISION ###############

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_seminar
      @seminar = Seminar.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def seminar_params
      params.require(:seminar).permit(:course_type_id, :name, :description, :start_at)
    end
end
