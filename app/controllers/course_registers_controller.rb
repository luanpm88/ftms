class CourseRegistersController < ApplicationController
  include CourseRegistersHelper
  
  load_and_authorize_resource
  
  before_action :set_course_register, only: [:show, :edit, :update, :destroy]
  
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
    @course_register.update_books_contacts(params[:books_contacts])
    
    authorize! :add_course, @course_register.contact
    
    respond_to do |format|
      if @course_register.save    
        Contact.find(@course_register.contact.id).update_info
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab?contact_id=#{params[:contact_id]}" : @course_register, notice: 'Course register was successfully created.' }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course_register
      @course_register = CourseRegister.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_register_params
      params.require(:course_register).permit(:debt_date, :invoice_required, :vat_name, :vat_code, :vat_address, :discount, :contact_id, :mailing_address, :payment_type, :bank_account_id, :discount_program_id, :created_date, :user_id)
    end
end
