class CourseRegistersController < ApplicationController
  include CourseRegistersHelper
  
  load_and_authorize_resource
  
  before_action :set_course_register, only: [:delete, :show, :edit, :update, :destroy]
  
  # GET /course_registers
  # GET /course_registers.json
  def index
    @course_registers = CourseRegister.all
  end

  # GET /course_registers/1
  # GET /course_registers/1.json
  def show
    @contact = @course_register.contact
  end

  # GET /course_registers/new
  def new
    @course_register = CourseRegister.new
    @contact = !params[:contact_id].present? ? Contact.new : Contact.find(params[:contact_id])
    
    @course_register.created_date = Time.now.strftime("%d-%b-%Y")
    @course_register.debt_date = Time.now.strftime("%d-%b-%Y")
    @course_register.mailing_address = @contact.default_mailing_address
    @course_register.contact_id = @contact.id
  end

  # GET /course_registers/1/edit
  def edit
  end

  # POST /course_registers
  # POST /course_registers.json
  def create
    @course_register = CourseRegister.new(course_register_params)
    @course_register.user = current_user    
    @course_register.update_contacts_courses(params[:contacts_courses])
    @course_register.update_books_contacts(params[:books_contacts]) if !params[:books_contacts].nil?
    
    @course_register.account_manager = @course_register.contact.account_manager
    
    authorize! :add_course, @course_register.contact
    
    respond_to do |format|
      if @course_register.save    
        Contact.find(@course_register.contact.id).update_info
        
        @course_register.update_status("create", current_user)        
        @course_register.save_draft(current_user)
        
        @tab = {url: {controller: "contacts", action: "edit", id: @course_register.contact.id, tab_page: 1, tab: "course_registration"}, title: @course_register.contact.display_name}
        format.html { render "/home/close_tab", layout: nil }
        format.json { render action: 'show', status: :created, location: @course_register }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @course_register.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /course_registers/1
  # PATCH/PUT /course_registers/1.json
  def update
    respond_to do |format|
      if @course_register.update(course_register_params)
        
        @course_register.update_status("update", current_user)        
        @course_register.save_draft(current_user)
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @course_register, notice: 'Course register was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @course_register.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /course_registers/1
  # DELETE /course_registers/1.json
  def destroy
    @course_register.destroy
    respond_to do |format|
      format.html { redirect_to course_registers_url }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = CourseRegister.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_course_register_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def student_course_registers
    result = CourseRegister.student_course_registers(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_course_register_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  ########## BEGIN REVISION ###############
  
  def approve_new
    authorize! :approve_new, @course_register
    
    @course_register.approve_new(current_user)
    
    respond_to do |format|
      format.html { render "/course_registers/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @course_register }
    end
  end
  
  def approve_update
    authorize! :approve_update, @course_register
    
    @course_register.approve_update(current_user)
    
    respond_to do |format|
      format.html { render "/course_registers/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @course_register }
    end
  end
  
  def approve_delete
    authorize! :approve_delete, @course_register
    
    @course_register.approve_delete(current_user)
    
    respond_to do |format|
      format.html { render "/course_registers/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @course_register }
    end
  end
  
  def approved
    render layout: "content"
  end
  
  def field_history
    @drafts = @course_register.field_history(params[:type])
    
    render layout: nil
  end

  def delete
    
    respond_to do |format|
      if @course_register.delete
        @course_register.save_draft(current_user)
        
        format.html { redirect_to "/home/close_tab" }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @course_register.errors, status: :unprocessable_entity }
      end
    end
  end
  
  ########## BEGIN REVISION ###############

  def export_student_course
    if params[:ids].present?
      if !params[:check_all_page].nil?
        params[:intake_year] = params["filter"]["intake(1i)"] if params["filter"].present?
        params[:intake_month] = params["filter"]["intake(2i)"] if params["filter"].present?
        
        @course_registers = CourseRegister.filter(params, current_user)
      else
        @course_registers = CourseRegister.where(id: params[:ids])
      end
    end      
    render layout: "content"
  end
  
  def add_stocks
    if params[:ids].present?
      if !params[:check_all_page].nil?
        params[:intake_year] = params["filter"]["intake(1i)"] if params["filter"].present?
        params[:intake_month] = params["filter"]["intake(2i)"] if params["filter"].present?
        
        if params[:is_individual] == "false"
          params[:contact_types] = nil
        end        
        
        @contacts = Contact.filters(params, current_user)
      else
        @contacts = Contact.where(id: params[:ids])
      end
    end
    
    @course_register = CourseRegister.new    
    
    render layout: "content"
  end
  
  def do_add_stocks    
    params[:contact_ids].each do |cid|
      @course_register = CourseRegister.new(course_register_params)
      @course_register.user = current_user
      @course_register.contact_id = cid
      @course_register.update_books_contacts(params[:books_contacts]) if !params[:books_contacts].nil?      
      @course_register.account_manager_id = Contact.find(cid).account_manager
      
      if !@course_register.books_contacts.empty?
        @course_register.save
        @course_register.add_status("active")        
        @course_register.save_draft(current_user)
      end
    end
    
    respond_to do |format|
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @course_register, notice: 'Course register was successfully created.' }
        format.json { render action: 'show', status: :created, location: @course_register }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course_register
      @course_register = CourseRegister.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_register_params
      params.require(:course_register).permit(:sponsored_company_id, :transfer, :transfer_hour, :debt_date, :invoice_required, :vat_name, :vat_code, :vat_address, :discount, :contact_id, :mailing_address, :payment_type, :bank_account_id, :discount_program_id, :created_date, :user_id)
    end
end
