class BankAccountsController < ApplicationController
  include BankAccountsHelper
  
  load_and_authorize_resource
  
  before_action :set_bank_account, only: [:delete, :show, :edit, :update, :destroy]

  # GET /bank_accounts
  # GET /bank_accounts.json
  def index
    @bank_accounts = BankAccount.all
    
    respond_to do |format|
      format.html { render layout: "content" if params[:tab_page].present? }
      format.json {
        render json: BankAccount.full_text_search(params[:q])
      }
    end
  end

  # GET /bank_accounts/1
  # GET /bank_accounts/1.json
  def show
  end

  # GET /bank_accounts/new
  def new
    @bank_account = BankAccount.new
  end

  # GET /bank_accounts/1/edit
  def edit
  end

  # POST /bank_accounts
  # POST /bank_accounts.json
  def create
    @bank_account = BankAccount.new(bank_account_params)
    @bank_account.user = current_user

    respond_to do |format|
      if @bank_account.save
        @bank_account.update_status("create", current_user)        
        @bank_account.save_draft(current_user)
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @bank_account, notice: 'Bank account was successfully created.' }
        format.json { render action: 'show', status: :created, location: @bank_account }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @bank_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bank_accounts/1
  # PATCH/PUT /bank_accounts/1.json
  def update
    respond_to do |format|
      if @bank_account.update(bank_account_params)
        @bank_account.update_status("update", current_user)        
        @bank_account.save_draft(current_user)
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @bank_account, notice: 'Bank account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @bank_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bank_accounts/1
  # DELETE /bank_accounts/1.json
  def destroy
    @bank_account.destroy
    respond_to do |format|
      format.html { redirect_to bank_accounts_url }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = BankAccount.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_bank_account_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  ########## BEGIN REVISION ###############
  
  def approve_new
    authorize! :approve_new, @bank_account
    
    @bank_account.approve_new(current_user)
    
    respond_to do |format|
      format.html { render "/bank_accounts/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @bank_account }
    end
  end
  
  def approve_update
    authorize! :approve_update, @bank_account
    
    @bank_account.approve_update(current_user)
    
    respond_to do |format|
      format.html { render "/bank_accounts/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @bank_account }
    end
  end
  
  def approve_delete
    authorize! :approve_delete, @bank_account
    
    @bank_account.approve_delete(current_user)
    
    respond_to do |format|
      format.html { render "/bank_accounts/deleted", layout: nil }
      format.json { render action: 'show', status: :created, location: @bank_account }
    end
  end
  
  def undo_delete
    authorize! :undo_delete, @bank_account
    
    @bank_account.undo_delete(current_user)
    
    respond_to do |format|
      format.html { render "/bank_accounts/undo_delete", layout: nil }
      format.json { render action: 'show', status: :created, location: @bank_account }
    end
  end
  
  def approved
    render layout: "content"
  end
  
  def field_history
    @drafts = @bank_account.field_history(params[:type])
    
    render layout: nil
  end

  def delete
    
    respond_to do |format|
      if @bank_account.delete
        @bank_account.save_draft(current_user)
        
        format.html { render "/bank_accounts/deleted", layout: nil }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @bank_account.errors, status: :unprocessable_entity }
      end
    end
  end
  
  ########## BEGIN REVISION ###############

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bank_account
      @bank_account = BankAccount.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bank_account_params
      params.require(:bank_account).permit(:name, :bank_name, :account_name, :account_number, :user_id)
    end
end
