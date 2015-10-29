class PhrasesController < ApplicationController
  include PhrasesHelper
  
  load_and_authorize_resource
  
  before_action :set_phrase, only: [:delete, :show, :edit, :update, :destroy]

  # GET /phrases
  # GET /phrases.json
  def index
    @phrases = Phrase.all
    
    respond_to do |format|
      format.html { render layout: "content" if params[:tab_page].present? }
      format.json {
        render json: Phrase.full_text_search(params)
      }
    end
  end

  # GET /phrases/1
  # GET /phrases/1.json
  def show
  end

  # GET /phrases/new
  def new
    @phrase = Phrase.new
    
    @subjects = Subject.active_subjects
    @subjects = @subjects.includes(:course_types).where(course_types: {id: @phrase.course_type_id}).order("subjects.name") if @phrase.course_type_id.present?
  end

  # GET /phrases/1/edit
  def edit
    @subjects = Subject.active_subjects
    @subjects = @subjects.includes(:course_types).where(course_types: {id: @phrase.course_type_id}).order("subjects.name") if @phrase.course_type_id.present?
  end

  # POST /phrases
  # POST /phrases.json
  def create    
    s_params = phrase_params
    #s_params[:subject_ids] = phrase_params[:subject_ids][0].split(",") if phrase_params[:subject_ids].present?
    
    @phrase = Phrase.new(s_params)
    @phrase.user = current_user
    
    respond_to do |format|
      if @phrase.save
        @phrase.update_status("create", current_user)        
        @phrase.save_draft(current_user)
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @phrase, notice: 'Phrase was successfully created.' }
        format.json { render action: 'show', status: :created, location: @phrase }
      else
        @subjects = Subject.active_subjects
        @subjects = @subjects.includes(:course_types).where(course_types: {id: @phrase.course_type_id}).order("subjects.name") if @phrase.course_type_id.present?
    
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @phrase.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /phrases/1
  # PATCH/PUT /phrases/1.json
  def update
    s_params = phrase_params
    #s_params[:subject_ids] = phrase_params[:subject_ids][0].split(",") if phrase_params[:subject_ids].present?
    
    respond_to do |format|
      if @phrase.update(s_params)
        @phrase.update_status("update", current_user)        
        @phrase.save_draft(current_user)
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @phrase, notice: 'Phrase was successfully updated.' }
        format.json { head :no_content }
      else
        @subjects = Subject.active_subjects
        @subjects = @subjects.includes(:course_types).where(course_types: {id: @phrase.course_type_id}).order("subjects.name") if @phrase.course_type_id.present?
        
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @phrase.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /phrases/1
  # DELETE /phrases/1.json
  def destroy
    @phrase.destroy
    respond_to do |format|
      format.html { redirect_to phrases_url }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = Phrase.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_phrase_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  ########## BEGIN REVISION ###############
  
  def approve_new
    authorize! :approve_new, @phrase
    
    @phrase.approve_new(current_user)
    
    respond_to do |format|
      format.html { render "/phrases/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @phrase }
    end
  end
  
  def approve_update
    authorize! :approve_update, @phrase
    
    @phrase.approve_update(current_user)
    
    respond_to do |format|
      format.html { render "/phrases/approved", layout: nil }
      format.json { render action: 'show', status: :created, location: @phrase }
    end
  end
  
  def approve_delete
    authorize! :approve_delete, @phrase
    
    @phrase.approve_delete(current_user)
    
    respond_to do |format|
      format.html { render "/phrases/deleted", layout: nil }
      format.json { render action: 'show', status: :created, location: @phrase }
    end
  end
  
  def undo_delete
    authorize! :undo_delete, @phrase
    
    @phrase.undo_delete(current_user)
    
    respond_to do |format|
      format.html { render "/phrases/undo_delete", layout: nil }
      format.json { render action: 'show', status: :created, location: @phrase }
    end
  end
  
  def approved
    render layout: "content"
  end
  
  def field_history
    @drafts = @phrase.field_history(params[:type])
    
    render layout: nil
  end

  def delete
    
    respond_to do |format|
      if @phrase.delete
        @phrase.save_draft(current_user)
        
        format.html { render "/phrases/deleted", layout: nil }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @phrase.errors, status: :unprocessable_entity }
      end
    end
  end
  
  ########## BEGIN REVISION ###############

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phrase
      @phrase = Phrase.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def phrase_params
      params.require(:phrase).permit(:course_type_id, :course_type_id, :name, :description, :subject_ids => [])
    end
end
