class BooksController < ApplicationController
  include BooksHelper
  
  before_action :set_book, only: [:delete, :cover, :show, :edit, :update, :destroy]
  
  load_and_authorize_resource :except => [:cover]

  # GET /books
  # GET /books.json
  def index
    @books = Book.all
    
    respond_to do |format|
      format.html
      format.json {
        render json: Book.full_text_search(params)
      }
    end
  end

  # GET /books/1
  # GET /books/1.json
  def show
  end

  # GET /books/new
  def new
    @book = Book.new
    
    if params[:parent_id]
      @book.parent = Book.find(params[:parent_id])
    end
    
    @subjects = Subject.active_subjects
    
  end

  # GET /books/1/edit
  def edit
    @subjects = Subject.active_subjects
    @subjects = @subjects.includes(:course_types).where(course_types: {id: @book.course_type_id}).order("subjects.name") if @book.course_type_id.present?
  end

  # POST /books
  # POST /books.json
  def create
    params[:subject_ids].each do |su_id|
      params[:stock_type_ids].each do |stid|
        @book = Book.new(book_params)
        @book.subject_id = su_id
        @book.user = current_user
        @book.stock_type_id = stid
        
        @book.save
        
        new_price = @book.book_prices.new(prices: params[:book_prices], user_id: current_user.id)
        @book.update_price(new_price)
        
        @book.update_status("create", current_user)        
        @book.save_draft(current_user)
        
        @book.check_out_of_date
      end
    end

    respond_to do |format|
      if true        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @book, notice: 'Book was successfully created.' }
        format.json { render action: 'show', status: :created, location: @book }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        new_price = @book.book_prices.new(prices: params[:book_prices], user_id: current_user.id)
        @book.update_price(new_price)
        
        @book.update_status("update", current_user)        
        @book.save_draft(current_user)
        
        @book.update_cache_search
        
        @book.check_out_of_date
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @book, notice: 'Book was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    @book.destroy
    respond_to do |format|
      format.html { redirect_to books_url }
      format.json { head :no_content }
    end
  end
  
  def cover
    send_file @book.cover_path(params[:type]), :disposition => 'inline'
  end
  
  def datatable
    result = Book.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_book_actions(item)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def student_books
    result = Book.student_books(params, current_user)
    @student = Contact.find(params[:student])
    
    result[:items].each_with_index do |item, index|
      actions = render_student_book_actions(item, @student)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def statistics
    result = Book.statistics(params, current_user)
    
    #result[:items].each_with_index do |item, index|
    #  actions = render_book_actions(item)
    #  
    #  result[:result]["data"][index][result[:actions_col]] = actions
    #end
    #
    render json: result[:result]
  end
  
  def stock_select
    @books = Book.filter(params, current_user)

    render layout: nil
  end
  
  def volumn_checkboxs
    if !params[:id].present?
      render nothing: true
    else
      @books = Book.find(params[:id])
      render layout: nil
    end   
  end
  
  def stock_price_form
    if !params[:id].present?
      render nothing: true
    else
      @books = Book.find(params[:id])
      render layout: nil
    end
  end
  
  ########## BEGIN REVISION ###############
  
  def approve_new
    authorize! :approve_new, @book
    
    @book.approve_new(current_user)
    
    respond_to do |format|
      format.html { render "/books/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @book }
    end
  end
  
  def approve_update
    authorize! :approve_update, @book
    
    @book.approve_update(current_user)
    
    respond_to do |format|
      format.html { render "/books/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @book }
    end
  end
  
  def approve_delete
    authorize! :approve_delete, @book
    
    @book.approve_delete(current_user)
    
    respond_to do |format|
      format.html { render "/books/deleted", layout: nil }
      format.json { render action: 'show', status: :created, location: @book }
    end
  end
  
  def undo_delete
    authorize! :undo_delete, @book
    
    @book.undo_delete(current_user)
    
    respond_to do |format|
      format.html { render "/books/undo_delete", layout: nil }
      format.json { render action: 'show', status: :created, location: @book }
    end
  end
  
  def approved
    render layout: "content"
  end
  
  def field_history
    @drafts = @book.field_history(params[:type])
    
    render layout: nil
  end

  def delete
    
    respond_to do |format|
      if @book.delete
        @book.save_draft(current_user)
        
        format.html { render "/books/deleted", layout: nil }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end
  
  ########## BEGIN REVISION ###############
  
  def stock_form_list
    records = []
    
    # @intake = Time.now.beginning_of_month
    
    if params[:subject_id].present?
      records = Book.joins(:course_type, :subject, :stock_type).main_books.order("course_types.short_name, subjects.name, stock_types.display_order, books.created_at")
      records = records.where(stock_type_id: params[:stock_type_id].split(",")) if params[:stock_type_id].present?
      records = records.where(course_type_id: params[:program_id].split(",")) if params[:program_id].present?
      records = records.where(subject_id: params[:subject_id].split(",")) if params[:subject_id].present?
      #records = records.where("valid_from <= ?", Time.now).where("valid_to >= ?", Time.now)
      records = records.where("valid_from <= ?", params[:valid_on].to_datetime.beginning_of_day) if params[:valid_on].present?
      records = records.where("valid_to >= ?", params[:valid_on].to_datetime.end_of_day) if params[:valid_on].present?
      
    end
    
    @books = []
    if params[:contact_id] != "undefined"
      contact = Contact.find(params[:contact_id])      
      records.each do |r|
        @books << r # if !r.registered?(contact)
      end
    else
      @books = records
    end
    
    render layout: nil
  end
  
  def delivery    
    render layout: "content"
  end
  
  def import_export
    render layout: "content"
  end
  
  def delivery_note
    if params[:ids].present?
      if !params[:check_all_page].nil?
        params[:intake_year] = params["filter"]["intake(1i)"] if params["filter"].present?
        params[:intake_month] = params["filter"]["intake(2i)"] if params["filter"].present?
        
        if params[:is_individual] == "false"
          params[:contact_types] = nil
        end        
        
        @books_contacts = BooksContact.filter(params, current_user)
      else
        @books_contacts = BooksContact.where(id: params[:ids])
      end
    end
    
    @books_contacts = @books_contacts.joins(:course_register, :book => [:course_type, :subject, :stock_type]).order("course_types.short_name, subjects.name, stock_types.display_order, books.created_at")
    
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
    #
    #@list += @list
    #@list += @list
    #@list += @list
    #@list += @list
    #@list += @list
    #@list += @list
    #@list += @list
    
    #respond_to do |format|
    #    format.html { render 'books/delivery_note.pdf.erb' }
    #    format.json { head :no_content }
    #end
    
    render  :pdf => "delivery_note_"+Time.now.strftime("%d_%b_%Y"),
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
  
  def deliver_all
    if params[:ids].present?
      if !params[:check_all_page].nil?
        params[:intake_year] = params["filter"]["intake(1i)"] if params["filter"].present?
        params[:intake_month] = params["filter"]["intake(2i)"] if params["filter"].present?
        
        if params[:is_individual] == "false"
          params[:contact_types] = nil
        end        
        
        @books_contacts = BooksContact.filter(params, current_user)
      else
        @books_contacts = BooksContact.where(id: params[:ids])
      end
    end
    
    @course_registers = CourseRegister.where(id: @books_contacts.map(&:course_register_id))
    
    @course_registers.each do |cr|
      delivery = Delivery.new
      delivery.course_register = cr
      delivery.user = current_user
      delivery.contact = cr.contact
      delivery.delivery_date = Time.now
      delivery.status = 1
      
      cr.books_contacts.each do |bc|
        if @books_contacts.include?(bc) && !bc.delivered?
          delivery.save
          delivery.delivery_details.create(book_id: bc.book_id, quantity: bc.remain)
        end        
      end
      
      delivery.save if !delivery.delivery_details.empty?
    end
    
    respond_to do |format|
        format.html { render "/books/delivered", layout: nil }
        format.json { head :no_content }
    end
  end
  
  def delivery_counting
    if params[:ids].present?
      if !params[:check_all_page].nil?
        params[:intake_year] = params["filter"]["intake(1i)"] if params["filter"].present?
        params[:intake_month] = params["filter"]["intake(2i)"] if params["filter"].present?
        
        if params[:is_individual] == "false"
          params[:contact_types] = nil
        end        
        
        @books_contacts = BooksContact.filter(params, current_user)
      else
        @books_contacts = BooksContact.where(id: params[:ids])
      end
    end
    
    # STATISTICS
    @counting = []
    if @books_contacts.present?        
      course_types = CourseType.where(id: Book.where(id: @books_contacts.map(&:book_id)).map(&:course_type_id)).order(:short_name)
      course_types.each do |ct|
        row = {}
        row[:course_type] = ct
        bcs = @books_contacts.includes(:book => :course_type).where(course_types: {id: ct.id})
        row[:count] = 0
        bcs.each do |bc|
          row[:count] += bc.remain
        end
        
        @counting << row if row[:count] > 0
      end
    end
    
    render layout: nil
  end
  
  def stock_statistics
    if params[:from_date].present? && params[:to_date].present?
      @from_date = params[:from_date].to_date
      @to_date =  params[:to_date].to_date.end_of_day
    else
      @from_date = DateTime.now.beginning_of_month
      @to_date =  DateTime.now
    end
  end
  
  def approve_all
    if params[:ids].present?
      if !params[:check_all_page].nil?
        @items = Book.filter(params, current_user)
      else
        @items = Book.where(id: params[:ids])
      end
    end
    
    @items.each do |c|
      c.approve_delete(current_user) if current_user.can?(:approve_delete, c)
      c.approve_new(current_user) if current_user.can?(:approve_new, c)
      c.approve_update(current_user) if current_user.can?(:approve_update, c)
    end
    
    respond_to do |format|
      format.html { render "/books/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @book }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_params
      params.require(:book).permit(:valid_from, :valid_to, :stock_type_id, :subject_id, :course_type_id, :subject_ids, :course_type_ids, :name, :description, :user_id, :image, :pirce, :publisher, :parent_id)
    end
end
