class ContactTagsController < ApplicationController
  include ContactTagsHelper
  load_and_authorize_resource
  before_action :set_contact_tag, only: [:delete, :show, :edit, :update, :destroy]

  # GET /contact_tags
  # GET /contact_tags.json
  def index
    @contact_tags = ContactTag.all
    respond_to do |format|
      format.html
      format.json {
        render json: ContactTag.full_text_search(params[:q])
      }
    end
  end

  # GET /contact_tags/1
  # GET /contact_tags/1.json
  def show
  end

  # GET /contact_tags/new
  def new
    @contact_tag = ContactTag.new
  end

  # GET /contact_tags/1/edit
  def edit
  end

  # POST /contact_tags
  # POST /contact_tags.json
  def create
    @contact_tag = ContactTag.new(contact_tag_params)
    @contact_tag.user = current_user

    respond_to do |format|
      if @contact_tag.save
        @contact_tag.update_status("create", current_user)        
        @contact_tag.save_draft(current_user)
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @contact_tag, notice: 'Contact tag was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contact_tag }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @contact_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contact_tags/1
  # PATCH/PUT /contact_tags/1.json
  def update
    respond_to do |format|
      if @contact_tag.update(contact_tag_params)
        @contact_tag.update_status("update", current_user)        
        @contact_tag.save_draft(current_user)
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @contact_tag, notice: 'Contact tag was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @contact_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contact_tags/1
  # DELETE /contact_tags/1.json
  def destroy
    @contact_tag.destroy
    respond_to do |format|
      format.html { redirect_to contact_tags_url }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = ContactTag.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_contact_tag_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  ########## BEGIN REVISION ###############
  
  def approve_new
    authorize! :approve_new, @contact_tag
    
    @contact_tag.approve_new(current_user)
    
    respond_to do |format|
      format.html { render "/contact_tags/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @contact_tag }
    end
  end
  
  def approve_update
    authorize! :approve_update, @contact_tag
    
    @contact_tag.approve_update(current_user)
    
    respond_to do |format|
      format.html { render "/contact_tags/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @contact_tag }
    end
  end
  
  def approve_delete
    authorize! :approve_delete, @contact_tag
    
    @contact_tag.approve_delete(current_user)
    
    respond_to do |format|
      format.html { render "/contact_tags/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @contact_tag }
    end
  end
  
  def approved
    render layout: "content"
  end
  
  def field_history
    @drafts = @contact_tag.field_history(params[:type])
    
    render layout: nil
  end

  def delete
    
    respond_to do |format|
      if @contact_tag.delete
        @contact_tag.save_draft(current_user)
        
        format.html { redirect_to "/home/close_tab" }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @contact_tag.errors, status: :unprocessable_entity }
      end
    end
  end
  
  ########## BEGIN REVISION ###############

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact_tag
      @contact_tag = ContactTag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_tag_params
      params.require(:contact_tag).permit(:name, :description)
    end
end
