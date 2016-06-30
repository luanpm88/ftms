class TransfersController < ApplicationController
  include TransfersHelper
  
  load_and_authorize_resource
  
  before_action :set_transfer, only: [:pay_by_credit, :pay, :delete, :show, :edit, :update, :destroy]

  # GET /transfers
  # GET /transfers.json
  def index
    @transfers = Transfer.all
  end

  # GET /transfers/1
  # GET /transfers/1.json
  def show
  end

  # GET /transfers/new
  def new
    @transfer = Transfer.new
    @transfer.contact = Contact.find(params[:contact_id])
    @transfer.transfer_date = Time.now
    @transfer.transferred_contact = @transfer.contact
  end

  # GET /transfers/1/edit
  def edit
  end

  # POST /transfers
  # POST /transfers.json
  def create
    @transfer = Transfer.new(transfer_params)
    @transfer.user = current_user
    
    # if course -> ...
    if @transfer.full_course == true
      @transfer.courses_phrase_ids = "["+@transfer.course.courses_phrases.map(&:id).join("][")+"]" if !@transfer.course.courses_phrases.empty?
    else
      @transfer.courses_phrase_ids = "["+params[:from_courses_phrases].join("][")+"]" if params[:from_courses_phrases].present?
    end
    
    # if upfront -> course
    if @transfer.to_full_course == true
      @transfer.to_courses_phrase_ids = "["+@transfer.to_course.courses_phrases.map(&:id).join("][")+"]" if !@transfer.to_course.courses_phrases.empty?
    else
      @transfer.to_courses_phrase_ids = "["+params[:to_courses_phrases].join("][")+"]" if params[:to_courses_phrases].present?
    end

    
    @transfer.from_hour = params[:from_hours].to_json if params[:from_hours].present?

    respond_to do |format|
      if @transfer.save
        @transfer.update_status("create", current_user)        
        @transfer.save_draft(current_user)
        
        @tab = {url: {controller: "contacts", action: "edit", id: @transfer.contact.id, tab_page: 1, tab: "transfer"}, title: @transfer.contact.display_name}
        format.html { render "/home/close_tab", layout: nil }
        format.json { render action: 'show', status: :created, location: @transfer }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @transfer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transfers/1
  # PATCH/PUT /transfers/1.json
  def update
    @transfer.update(transfer_params)
    
    # if course -> ...
    if params[:full_course] == true
      @transfer.courses_phrase_ids = "["+@transfer.course.courses_phrases.map(&:id).join("][")+"]" if !@transfer.course.courses_phrases.empty?
    else
      @transfer.full_course = false
      @transfer.courses_phrase_ids = "["+params[:from_courses_phrases].join("][")+"]" if params[:from_courses_phrases].present?
    end
    
    # if upfront -> course
    if params[:to_full_course] == true
      @transfer.to_courses_phrase_ids = "["+@transfer.to_course.courses_phrases.map(&:id).join("][")+"]" if !@transfer.to_course.courses_phrases.empty?
    else
      @transfer.to_full_course = false
      @transfer.to_courses_phrase_ids = "["+params[:to_courses_phrases].join("][")+"]" if params[:to_courses_phrases].present?
    end

    
    @transfer.from_hour = params[:from_hours].to_json if params[:from_hours].present?
    
    respond_to do |format|
      if @transfer.save
        @transfer.update_status("update", current_user)        
        @transfer.save_draft(current_user)
        
         @tab = {url: {controller: "contacts", action: "edit", id: @transfer.contact.id, tab_page: 1, tab: "transfer"}, title: @transfer.contact.display_name}
        format.html { render "/home/close_tab", layout: nil }
        format.json { render action: 'show', status: :created, location: @transfer }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @transfer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transfers/1
  # DELETE /transfers/1.json
  def destroy
    @transfer.destroy
    respond_to do |format|
      format.html { redirect_to transfers_url }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = Transfer.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_transfer_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def pay_by_credit
    @transfer.pay_by_credit
    
    render html: "Transfer was successfully paid by deferred/transferred money.!".html_safe
  end
  
  ########## BEGIN REVISION ###############
  
  def approve_new
    authorize! :approve_new, @transfer
    
    @transfer.approve_new(current_user)
    
    respond_to do |format|
      format.html { render "/transfers/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @transfer }
    end
  end
  
  def approve_update
    authorize! :approve_update, @transfer
    
    @transfer.approve_update(current_user)
    
    respond_to do |format|
      format.html { render "/transfers/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @transfer }
    end
  end
  
  def approve_delete
    authorize! :approve_delete, @transfer
    
    @transfer.approve_delete(current_user)
    
    respond_to do |format|
      format.html { render "/transfers/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @transfer }
    end
  end
  
  def undo_delete
    authorize! :undo_delete, @transfer
    
    @transfer.undo_delete(current_user)
    
    respond_to do |format|
      format.html { render "/transfers/undo_delete", layout: nil }
      format.json { render action: 'show', status: :created, location: @transfer }
    end
  end
  
  def approved
    render layout: "content"
  end
  
  def field_history
    @drafts = @transfer.field_history(params[:type])
    
    render layout: nil
  end

  def delete    
    respond_to do |format|
      if @transfer.delete
        @transfer.save_draft(current_user)
        
        format.html { render "/transfers/deleted", layout: nil }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @transfer.errors, status: :unprocessable_entity }
      end
    end
  end
  
  ########## BEGIN REVISION ###############
  
  def pay
    @payment_record = @transfer.payment_records.new
    
    render layout: "content"
  end
  
  def do_pay
    #code
  end
  
  def transfer_hour
    @contact = Contact.find(params[:contact_id])
    @transfer = Transfer.new
    @transfer.contact = @contact
    @transfer.transfer_date = Time.now
    @transfer.transferred_contact = @transfer.contact
    
    if @contact.pending_transfer_count > 0
      @tab = {url: {controller: "contacts", action: "edit", id: @contact.id, tab_page: 1, tab: "transfer"}, title: @contact.display_name+" #"+@contact.id.to_s}
      flash[:alert] = 'Error: Previous transfer(s) must be approved first.!'
      render "/home/close_tab", layout: nil
    else
      render layout: "content"
    end   
  end
  
  def do_transfer_hour
    #code
  end
  
  def approve_all
    if params[:ids].present?
      if !params[:check_all_page].nil?
        @items = Transfer.filter(params, current_user)
      else
        @items = Transfer.where(id: params[:ids])
      end
    end
    
    @items.each do |c|
      c.approve_delete(current_user) if current_user.can?(:approve_delete, c)
      c.approve_new(current_user) if current_user.can?(:approve_new, c)
      c.approve_update(current_user) if current_user.can?(:approve_update, c)
    end
    
    respond_to do |format|
      format.html { render "/transfers/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @course_type }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transfer
      @transfer = Transfer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transfer_params
      params.require(:transfer).permit(:money_credit, :full_course, :to_full_course, :note, :hour_money, :from_hour, :to_type, :to_course_hour, :to_course_money, :to_course_id, :course_id, :admin_fee, :transfer_for, :contact_id, :to_contact_id, :user_id, :transfer_date, :hour, :money, :courses_phrase_ids => [])
    end
end
