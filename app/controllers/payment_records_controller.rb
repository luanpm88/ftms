class PaymentRecordsController < ApplicationController
  include PaymentRecordsHelper
  include CourseRegistersHelper
  
  load_and_authorize_resource
  
  before_action :set_payment_record, only: [:show, :edit, :update, :destroy]

  # GET /payment_records
  # GET /payment_records.json
  def index
    @payment_records = PaymentRecord.all
  end
  
  def payment_list
    #code
  end

  # GET /payment_records/1
  # GET /payment_records/1.json
  def show
  end

  # GET /payment_records/new
  def new
    @payment_record = PaymentRecord.new
    @course_register = CourseRegister.find(params[:course_register_id])
    @payment_record.course_register = @course_register
    
    @payment_record.payment_date = Time.now
    @payment_record.debt_date = Time.now
  end

  # GET /payment_records/1/edit
  def edit
  end

  # POST /payment_records
  # POST /payment_records.json
  def create
    @payment_record = PaymentRecord.new(payment_record_params)
    @payment_record.user = current_user
    @payment_record.status = 1
    @payment_record.update_payment_record_details(params[:payment_record_details]) if params[:payment_record_details].present?
    @payment_record.update_stock_payment_record_details(params[:stock_payment_record_details]) if params[:stock_payment_record_details].present?

    respond_to do |format|
      if @payment_record.save
        # create note log
        if params[:note_log].present?
          @payment_record.course_register.contact.activities.create(user_id: current_user.id, note: params[:note_log]) if params[:note_log].present?
        end
        
        #if !transfer.nil?
          @tab = {url: {controller: "contacts", action: "edit", id: @payment_record.course_register.contact.id, tab_page: 1, tab: "course_registration"}, title: @payment_record.course_register.contact.display_name+(@payment_record.course_register.contact.related_contacts.empty? ? "" : " #"+@payment_record.course_register.contact.id.to_s)}
        #end
        format.html { render "/home/close_tab", layout: nil }
        format.json { render action: 'show', status: :created, location: @payment_record }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @payment_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payment_records/1
  # PATCH/PUT /payment_records/1.json
  def update
    respond_to do |format|
      if @payment_record.update(payment_record_params)
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @payment_record, notice: 'Payment record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @payment_record.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def datatable
    result = PaymentRecord.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_payment_record_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def datatable_payment_list
    result = CourseRegister.payment_list(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_course_register_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end

  # DELETE /payment_records/1
  # DELETE /payment_records/1.json
  def destroy
    @payment_record.destroy
    respond_to do |format|
      format.html { redirect_to payment_records_url }
      format.json { head :no_content }
    end
  end
  
  def print
    render  :pdf => "payment_"+@payment_record.payment_date.strftime("%d_%b_%Y"),
            :template => 'payment_records/print.pdf.erb',
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
  
  def trash
    @payment_record.trash
    
    respond_to do |format|
      format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : payment_records_path, notice: 'Payment was successfully updated.' }
      format.json { head :no_content }
    end
  end
  
  def company_pay
    @old_record = PaymentRecord.find(params[:id]) if params[:id].present?
    if @old_record.nil?
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
      arr = []
      @course_registers.each do |cr|
        arr << cr if !cr.paid?
      end
      @course_registers = arr
    else
      @course_registers = @old_record.course_registers
    end
    
    
    
    course_type_ids = []
    @course_type_count= {}
    @stock_count = {}
    @display_count = {}
    @course_registers.each do |cr|        
      cr.contacts_courses.each do |cc|
        course_type_ids << cc.course.course_type_id
        @course_type_count[cc.course.course_type_id] = @course_type_count[cc.course.course_type_id].nil? ? 1 : @course_type_count[cc.course.course_type_id]+1
      end
      cr.books_contacts.each do |bc|
        course_type_ids << bc.book.course_type_id
        @stock_count[bc.book.course_type_id] = @stock_count[bc.book.course_type_id].nil? ? 1 : @stock_count[bc.book.course_type_id]+1
      end
    end
    
    
    
    @course_types = CourseType.where(id: course_type_ids).order("short_name")
    
    @payment_record = PaymentRecord.new    
    @payment_record.payment_date = Time.now
    @payment_record.debt_date = Time.now

    
    render layout: "content"
  end

  def do_company_pay
    @payment_record = PaymentRecord.new(payment_record_params)
    @payment_record.user = current_user
    @payment_record.status = 1
    @payment_record.update_company_payment_record_details(params[:payment_record_details]) if params[:payment_record_details].present?
    
    @payment_record.course_register_ids = "["+params[:course_register_ids].join("][")+"]" if !params[:old_record_id].present?

    respond_to do |format|
      if @payment_record.save
        #save old record        
        if params[:old_record_id].present?
          @payment_record.save_old_record(params[:old_record_id])
        end
        
        # create note log
        if params[:note_log].present?
          @payment_record.contact.activities.create(user_id: current_user.id, note: params[:note_log]) if params[:note_log].present?
        end
        
               
        
        @tab = {url: {controller: "payment_records", action: "index", tab_page: 1, tab: "course_registration"}}
        format.html { render "/home/close_tab", layout: nil }
        format.json { render action: 'show', status: :created, location: @payment_record }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @payment_record.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def print_payment_list
    
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
      
      @course_registers = @course_registers.includes(:contact).order("contacts.name, course_registers.contact_id")
      
      paper_ids = []
      
      @list = []
      @course_registers.each do |cr|        
        cr.contacts_courses.each do |cc|
          row = {}
          row[:contact_name] = cc.contact.name
          row[:course] = cc.course.display_name
          row[:phrases] = Phrase.where(id: cc.course.courses_phrases.includes(:phrase).map(&:phrase_id)).order("name").map(&:"name").join("; ")
          row[:company] = !cr.sponsored_company.nil? ? cr.sponsored_company.name : ""          
          
          row[:papers] = {}          
          row[:papers][cc.course.subject_id] = "X"          
          paper_ids << cc.course.subject_id
          
          if (params[:course_types].present? && !params[:course_types].include?(cc.course.course_type_id.to_s)) || (params[:subjects].present? && !params[:subjects].include?(cc.course.subject_id.to_s))
          else
            @list << row
          end
        end
      end
      
      @course_registers.each do |cr|        
        cr.books_contacts.each do |bc|
          row = {}
          row[:contact_name] = bc.contact.name
          row[:stock] = bc.book.display_name
          row[:company] = !cr.sponsored_company.nil? ? cr.sponsored_company.name : ""         
          
          row[:papers] = {}          
          row[:papers][bc.book.subject_id] = "X"          
          paper_ids << bc.book.subject_id
          
          if (params[:course_types].present? && !params[:course_types].include?(bc.book.course_type_id.to_s)) || (params[:subjects].present? && !params[:subjects].include?(bc.book.subject_id.to_s))
          else
            @list << row
          end
        end
      end

      
      @papers = Subject.where(id: paper_ids).order("name")
      
      respond_to do |format|
        format.html {render "print_payment_list.xls.erb"}
        format.xls
        format.pdf {
          render  :pdf => "payment_list_"+Time.now.strftime("%d_%b_%Y"),
            :template => 'payment_records/print_payment_list.pdf.erb',
            :layout => nil,
            :orientation => 'Landscape',
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
        }
      end
      
      
    end      
  end
  
  def pay_transfer
    @payment_record = PaymentRecord.new(payment_record_params)
    @payment_record.user = current_user
    @payment_record.status = 1
    
    respond_to do |format|
      if @payment_record.save
        # create note log
        if params[:note_log].present?
          @payment_record.transfer.contact.activities.create(user_id: current_user.id, note: params[:note_log]) if params[:note_log].present?
        end
        
        @tab = {url: {controller: "contacts", action: "edit", id: @payment_record.transfer.contact.id, tab_page: 1, tab: "transfer"}, title: @payment_record.transfer.contact.display_name}
        format.html { render "/home/close_tab", layout: nil }
        format.json { render action: 'show', status: :created, location: @payment_record }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @payment_record.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_record
      @payment_record = PaymentRecord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_record_params
      params.require(:payment_record).permit(:bank_ref, :account_manager_id, :transfer_id, :company_id, :bank_account_id, :payment_date, :course_register_id, :amount, :debt_date, :user_id, :note)
    end
end
