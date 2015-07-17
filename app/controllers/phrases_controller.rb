class PhrasesController < ApplicationController
  include PhrasesHelper
  
  load_and_authorize_resource
  
  before_action :set_phrase, only: [:show, :edit, :update, :destroy]

  # GET /phrases
  # GET /phrases.json
  def index
    @phrases = Phrase.all
    
    respond_to do |format|
      format.html { render layout: "content" if params[:tab_page].present? }
      format.json {
        render json: Phrase.full_text_search(params[:q])
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
  end

  # GET /phrases/1/edit
  def edit
  end

  # POST /phrases
  # POST /phrases.json
  def create    
    s_params = phrase_params
    s_params[:subject_ids] = phrase_params[:subject_ids][0].split(",") if phrase_params[:subject_ids].present?

    @phrase = Phrase.new(phrase_params)
    @phrase.user = current_user

    respond_to do |format|
      if @phrase.save
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @phrase, notice: 'Phrase was successfully created.' }
        format.json { render action: 'show', status: :created, location: @phrase }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @phrase.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /phrases/1
  # PATCH/PUT /phrases/1.json
  def update
    s_params = phrase_params
    s_params[:subject_ids] = phrase_params[:subject_ids][0].split(",") if phrase_params[:subject_ids].present?
    respond_to do |format|
      if @phrase.update(s_params)
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @phrase, notice: 'Phrase was successfully updated.' }
        format.json { head :no_content }
      else
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phrase
      @phrase = Phrase.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def phrase_params
      params.require(:phrase).permit(:name, :description, :subject_ids => [])
    end
end
