class SubjectsController < ApplicationController
  include SubjectsHelper
  
  load_and_authorize_resource
  
  before_action :set_subject, only: [:delete, :show, :edit, :update, :destroy]

  # GET /subjects
  # GET /subjects.json
  def index
    @subjects = Subject.all
    
    respond_to do |format|
      format.html { render layout: "content" if params[:tab_page].present? }
      format.json {
        render json: Subject.full_text_search(params[:q])
      }
    end
  end

  # GET /subjects/1
  # GET /subjects/1.json
  def show
  end

  # GET /subjects/new
  def new
    @subject = Subject.new
  end

  # GET /subjects/1/edit
  def edit
  end

  # POST /subjects
  # POST /subjects.json
  def create
    s_params = subject_params
    s_params[:course_type_ids] = subject_params[:course_type_ids][0].split(",") if subject_params[:course_type_ids].present?
    
    @subject = Subject.new(s_params)    
    @subject.user = current_user

    respond_to do |format|
      if @subject.save
        @subject.update_status("create", current_user)        
        @subject.save_draft(current_user)
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @subject, notice: 'Subject was successfully created.' }
        format.json { render action: 'show', status: :created, location: @subject }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subjects/1
  # PATCH/PUT /subjects/1.json
  def update
    s_params = subject_params
    s_params[:course_type_ids] = subject_params[:course_type_ids][0].split(",") if subject_params[:course_type_ids].present?
    respond_to do |format|
      if @subject.update(s_params)
        @subject.update_status("update", current_user)        
        @subject.save_draft(current_user)
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @subject, notice: 'Subject was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.json
  def destroy
    @subject.destroy
    respond_to do |format|
      format.html { redirect_to subjects_url(tab_page: 1) }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = Subject.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_subject_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def ajax_select_box
    render layout: nil
  end
  
  ########## BEGIN REVISION ###############
  
  def approve_new
    authorize! :approve_new, @subject
    
    @subject.approve_new(current_user)
    
    respond_to do |format|
      format.html { render "/subjects/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @subject }
    end
  end
  
  def approve_update
    authorize! :approve_update, @subject
    
    @subject.approve_update(current_user)
    
    respond_to do |format|
      format.html { render "/subjects/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @subject }
    end
  end
  
  def approve_delete
    authorize! :approve_delete, @subject
    
    @subject.approve_delete(current_user)
    
    respond_to do |format|
      format.html { render "/subjects/deleted", layout: nil }
      format.json { render action: 'show', status: :created, location: @subject }
    end
  end
  
  def undo_delete
    authorize! :undo_delete, @subject
    
    @subject.undo_delete(current_user)
    
    respond_to do |format|
      format.html { render "/subjects/undo_delete", layout: nil }
      format.json { render action: 'show', status: :created, location: @subject }
    end
  end
  
  def approved
    render layout: "content"
  end
  
  def field_history
    @drafts = @subject.field_history(params[:type])
    
    render layout: nil
  end

  def delete
    
    respond_to do |format|
      if @subject.delete
        @subject.save_draft(current_user)
        
        format.html { render "/subjects/deleted", layout: nil }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end
  
  ########## BEGIN REVISION ###############

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subject
      @subject = Subject.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subject_params
      params.require(:subject).permit(:name, :description, :course_type_ids => [])
    end
end
