class CoursesPhrasesController < ApplicationController
  before_action :set_courses_phrase, only: [:show, :edit, :update, :destroy]

  # GET /courses_phrases
  # GET /courses_phrases.json
  def index
    @courses_phrases = CoursesPhrase.all
  end

  # GET /courses_phrases/1
  # GET /courses_phrases/1.json
  def show
  end

  # GET /courses_phrases/new
  def new
    @courses_phrase = CoursesPhrase.new
  end

  # GET /courses_phrases/1/edit
  def edit
  end

  # POST /courses_phrases
  # POST /courses_phrases.json
  def create
    @courses_phrase = CoursesPhrase.new(courses_phrase_params)

    respond_to do |format|
      if @courses_phrase.save
        format.html { redirect_to @courses_phrase, notice: 'Courses phrase was successfully created.' }
        format.json { render action: 'show', status: :created, location: @courses_phrase }
      else
        format.html { render action: 'new' }
        format.json { render json: @courses_phrase.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses_phrases/1
  # PATCH/PUT /courses_phrases/1.json
  def update
    respond_to do |format|
      if @courses_phrase.update(courses_phrase_params)
        format.html { redirect_to @courses_phrase, notice: 'Courses phrase was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @courses_phrase.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses_phrases/1
  # DELETE /courses_phrases/1.json
  def destroy
    @courses_phrase.destroy
    respond_to do |format|
      format.html { redirect_to courses_phrases_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_courses_phrase
      @courses_phrase = CoursesPhrase.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def courses_phrase_params
      params.require(:courses_phrase).permit(:course_id, :phrase_id)
    end
end
