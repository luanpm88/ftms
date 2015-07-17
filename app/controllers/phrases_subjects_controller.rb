class PhrasesSubjectsController < ApplicationController
  before_action :set_phrases_subject, only: [:show, :edit, :update, :destroy]

  # GET /phrases_subjects
  # GET /phrases_subjects.json
  def index
    @phrases_subjects = PhrasesSubject.all
  end

  # GET /phrases_subjects/1
  # GET /phrases_subjects/1.json
  def show
  end

  # GET /phrases_subjects/new
  def new
    @phrases_subject = PhrasesSubject.new
  end

  # GET /phrases_subjects/1/edit
  def edit
  end

  # POST /phrases_subjects
  # POST /phrases_subjects.json
  def create
    @phrases_subject = PhrasesSubject.new(phrases_subject_params)

    respond_to do |format|
      if @phrases_subject.save
        format.html { redirect_to @phrases_subject, notice: 'Phrases subject was successfully created.' }
        format.json { render action: 'show', status: :created, location: @phrases_subject }
      else
        format.html { render action: 'new' }
        format.json { render json: @phrases_subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /phrases_subjects/1
  # PATCH/PUT /phrases_subjects/1.json
  def update
    respond_to do |format|
      if @phrases_subject.update(phrases_subject_params)
        format.html { redirect_to @phrases_subject, notice: 'Phrases subject was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @phrases_subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /phrases_subjects/1
  # DELETE /phrases_subjects/1.json
  def destroy
    @phrases_subject.destroy
    respond_to do |format|
      format.html { redirect_to phrases_subjects_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phrases_subject
      @phrases_subject = PhrasesSubject.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def phrases_subject_params
      params.require(:phrases_subject).permit(:phrase_id, :subject_id)
    end
end
