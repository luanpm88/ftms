class CourseRegistersController < ApplicationController
  include CourseRegistersHelper
  
  load_and_authorize_resource
  
  before_action :set_course_register, only: [:part_info, :delivery_print, :delete, :show, :edit, :update, :destroy]
  
  # GET /course_registers
  # GET /course_registers.json
  def index
    @course_registers = CourseRegister.all
    @course = Course.find(params[:course_id]) if params[:course_id].present?
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
    
    @course_register.payment_type = @contact.payment_type
    @course_register.sponsored_company = @contact.referrer if !@contact.referrer.nil?
    
    
    @course_register.created_date = Time.now.strftime("%d-%b-%Y")
    @course_register.debt_date = Time.now.strftime("%d-%b-%Y")
    @course_register.mailing_address = @contact.default_mailing_address
    @course_register.contact_id = @contact.id
  end

  # GET /course_registers/1/edit
  def edit
    @contact = @course_register.contact
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
        
        @tab = {url: {controller: "contacts", action: "edit", id: @course_register.contact.id, tab_page: 1, tab: "course_registration"}, title: @course_register.contact.display_name+(@course_register.contact.related_contacts.empty? ? "" : " #"+@course_register.contact.id.to_s)}
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
    @course_register.update_contacts_courses(params[:contacts_courses]) if !params[:contacts_courses].nil?
    @course_register.update_books_contacts(params[:books_contacts]) if !params[:books_contacts].nil?
    
    respond_to do |format|
      if @course_register.save and @course_register.update(course_register_params)
        
        Contact.find(@course_register.contact.id).update_info
        
        @course_register.update_statuses
        
        @course_register.update_status("update", current_user)        
        @course_register.save_draft(current_user)
        
        # update payment status
        @course_register.all_payment_records.each do |pr|
          pr.update_statuses
          pr.update_cache_search
        end        
        
        @tab = {url: {controller: "contacts", action: "edit", id: @course_register.contact.id, tab_page: 1, tab: "course_registration"}, title: @course_register.contact.display_name+(@course_register.contact.related_contacts.empty? ? "" : " #"+@course_register.contact.id.to_s)}
        format.html { render "/home/close_tab", layout: nil }
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
    
    respond_to do |format|
      if @course_register.approve_new(current_user)
        Contact.find(@course_register.contact.id).update_info
        
        format.html { render "/course_registers/approved", layout: nil }
        format.json { render action: 'show', status: :created, location: @course_register }
      else
        format.html { render "/course_registers/not_valid", layout: nil }
        format.json { render action: 'show', status: :created, location: @course_register }
      end
      
    end
    
    
  end
  
  def approve_update
    authorize! :approve_update, @course_register
    
    respond_to do |format|
      if @course_register.approve_update(current_user)
        Contact.find(@course_register.contact.id).update_info
        
        format.html { render "/course_registers/approved", layout: nil }
        format.json { render action: 'show', status: :created, location: @course_register }
      else
        format.html { render "/course_registers/not_valid", layout: nil }
        format.json { render action: 'show', status: :created, location: @course_register }
      end
      
    end
  end
  
  def approve_delete
    authorize! :approve_delete, @course_register
    
    @course_register.approve_delete(current_user)
    
    Contact.find(@course_register.contact.id).update_info
    
    respond_to do |format|
      format.html { render "/course_registers/deleted", layout: nil }
      format.json { render action: 'show', status: :created, location: @course_register }
    end
  end
  
  def undo_delete
    authorize! :undo_delete, @course_register
    
    @course_register.undo_delete(current_user)
    
    respond_to do |format|
      if @course_register.undo_delete(current_user)
        Contact.find(@course_register.contact.id).update_info
        
        format.html { render "/course_registers/approved", layout: nil }
        format.json { render action: 'show', status: :created, location: @course_register }
      else
        format.html { render "/course_registers/not_valid", layout: nil }
        format.json { render action: 'show', status: :created, location: @course_register }
      end
      
    end
  end
  
  def approve_all
    authorize! :approve_all, CourseRegister
    
    if params[:ids].present?
      if !params[:check_all_page].nil?
        params[:intake_year] = params["filter"]["intake(1i)"] if params["filter"].present?
        params[:intake_month] = params["filter"]["intake(2i)"] if params["filter"].present?
        
        if params[:is_individual] == "false"
          params[:contact_types] = nil
        end        
        
        @course_registers = CourseRegister.filter(params, current_user)
      else
        @course_registers = CourseRegister.where(id: params[:ids])
      end
    end
    
    @course_registers.each do |cr|
      cr.approve_delete(current_user) if current_user.can?(:approve_delete, cr)
      cr.approve_new(current_user) if current_user.can?(:approve_new, cr)
      cr.approve_update(current_user) if current_user.can?(:approve_update, cr)
      
      Contact.find(cr.contact.id).update_info
    end
    
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
        
        Contact.find(@course_register.contact.id).update_info
        
        format.html { render "/course_registers/deleted", layout: nil }
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
    
    
    if params[:courses].present? and !Course.find(params[:courses]).courses_phrases.empty?
      phrase_pattern = (Course.find(params[:courses]).courses_phrases.map {|cp| "contacts.cache_transferred_courses_phrases LIKE '%[#{cp.id.to_s}]%'"}).join(" OR ")
      @contacts = @contacts.select("*, CASE WHEN (#{phrase_pattern}) THEN 0 WHEN contacts.cache_courses LIKE '%[#{params[:courses]},half]%' THEN 1 ELSE 2 END AS transferred_order")
      @contacts = @contacts.order("transferred_order, name")
    end
    
    
    @course = params[:courses].present? ? Course.find(params[:courses]) : nil
    
    @course_register = CourseRegister.new    
    
    render layout: "content"
  end
  
  def do_add_stocks    
    params[:contact_ids].each do |cid|
      @course_register = CourseRegister.new(course_register_params)
      @course_register.user = current_user
      @course_register.contact_id = cid
      @course_register.update_books_contacts(params[:books_contacts], params[:course_id]) if !params[:books_contacts].nil?      
      @course_register.account_manager_id = Contact.find(cid).account_manager
      @course_register.account_manager = Contact.find(cid).account_manager
      
      if !@course_register.books_contacts.empty?
        @course_register.save
        @course_register.add_status("active")        
        @course_register.save_draft(current_user)
        @course_register.contact.update_info
      end
    end
    
    respond_to do |format|
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @course_register, notice: 'Course register was successfully created.' }
        format.json { render action: 'show', status: :created, location: @course_register }
    end
  end
  
  def delivery_print
    @books_contacts = @course_register.books_contacts
    
    @list = []
    row = nil
    @books_contacts.each_with_index do |bc,index|
      if row.nil? || row[:contact] != bc.contact || row[:address] != bc.course_register.display_mailing_address
        @list << row if !row.nil?
        
        row = {}
        row[:contact] = bc.contact
        row[:address] = bc.course_register.display_mailing_address
        row[:address_title] = bc.course_register.display_mailing_title
        row[:list] = !bc.delivered? ? {bc.contact_id.to_s+"_"+bc.book_id.to_s => bc} : {}
      else
        if !bc.delivered?
          if row[:list][bc.contact_id.to_s+"_"+bc.book_id.to_s].nil?
            row[:list][bc.contact_id.to_s+"_"+bc.book_id.to_s] = bc
            row[:list][bc.contact_id.to_s+"_"+bc.book_id.to_s].quantity = bc.remain
          else
            row[:list][bc.contact_id.to_s+"_"+bc.book_id.to_s].quantity += bc.remain
          end         
        end
      end
      
      @list << row if @books_contacts.count == index+1
    end
    
    render  :pdf => "delivery_"+@course_register.created_at.strftime("%d_%b_%Y"),
            :template => 'books/delivery_note.pdf.erb',
            :layout => nil,
            :footer => {
               :center => "",
               :left => "",
               :right => "",
               :page_size => "A4",
               :margin  => {:top    => 0, # default 10 (mm)
                          :bottom => 0,
                          :left   => 0,
                          :right  => 0},
            }
  end
  
  def part_info
    item = @course_register
    render json: {
      col_2: item.description,              #'<div class="text-center">'+item.display_delivery_status+"</div>",
      col_3: "<div class=\"text-right\">#{item.display_amounts}</div>",
      col_4: '<div class="text-center">'+item.display_payment_status+item.display_payment+item.display_delivery_status+"</div>",
      col_5: '<div class="text-center">'+item.created_at.strftime("%d-%b-%Y")+"<br /><strong>by:</strong><br />"+item.user.staff_col+"</div>",
      col_6: '<div class="text-center">'+item.account_manager.staff_col+"</div>",
      col_7: '<div class="text-center">'+item.display_statuses+"</div>"
    }
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
