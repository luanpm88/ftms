class TransfersController < ApplicationController
  include TransfersHelper
  
  load_and_authorize_resource
  
  before_action :set_transfer, only: [:delete, :show, :edit, :update, :destroy]

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
    # @transfer.update_transfer_details(params[:transfer_details])
    @transfer.courses_phrase_ids = "["+params[:from_courses_phrases].join("][")+"]" if params[:from_courses_phrases].present?
    @transfer.to_courses_phrase_ids = "["+params[:to_courses_phrases].join("][")+"]" if params[:to_courses_phrases].present?

    respond_to do |format|
      if @transfer.save
        @transfer.update_status("create", current_user)        
        @transfer.save_draft(current_user)
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @transfer, notice: 'Transfer was successfully created.' }
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
    respond_to do |format|
      if @transfer.update(transfer_params)
        @transfer.update_status("update", current_user)        
        @transfer.save_draft(current_user)
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @transfer, notice: 'Transfer was successfully updated.' }
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
  
  ########## BEGIN REVISION ###############
  
  def approve_new
    authorize! :approve_new, @transfer
    
    @transfer.approve_new(current_user)
    
    respond_to do |format|
      format.html { redirect_to params[:tab_page].present? ? "/transfers/approved" : @transfer }
      format.json { render action: 'show', status: :created, location: @transfer }
    end
  end
  
  def approve_update
    authorize! :approve_update, @transfer
    
    @transfer.approve_update(current_user)
    
    respond_to do |format|
      format.html { redirect_to params[:tab_page].present? ? "/transfers/approved" : @transfer }
      format.json { render action: 'show', status: :created, location: @transfer }
    end
  end
  
  def approve_delete
    authorize! :approve_delete, @transfer
    
    @transfer.approve_delete(current_user)
    
    respond_to do |format|
      format.html { redirect_to params[:tab_page].present? ? "/transfers/approved" : @transfer }
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
        
        format.html { redirect_to "/home/close_tab" }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @transfer.errors, status: :unprocessable_entity }
      end
    end
  end
  
  ########## BEGIN REVISION ###############

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transfer
      @transfer = Transfer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transfer_params
      params.require(:transfer).permit(:to_course_id, :course_id, :admin_fee, :transfer_for, :contact_id, :to_contact_id, :user_id, :transfer_date, :hour, :money, :courses_phrase_ids => [])
    end
end
