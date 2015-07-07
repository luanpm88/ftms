class CourseTypesSubjectsController < ApplicationController
  before_action :set_course_types_subject, only: [:show, :edit, :update, :destroy]

  # GET /course_types_subjects
  # GET /course_types_subjects.json
  def index
    @course_types_subjects = CourseTypesSubject.all
    
    respond_to do |format|
      format.html { render layout: "content" if params[:tab_page].present? }
      format.json {
        render json: CourseTypesSubject.full_text_search(params[:q])
      }
    end
  end

  # GET /course_types_subjects/1
  # GET /course_types_subjects/1.json
  def show
  end

  # GET /course_types_subjects/new
  def new
    @course_types_subject = CourseTypesSubject.new
  end

  # GET /course_types_subjects/1/edit
  def edit
  end

  # POST /course_types_subjects
  # POST /course_types_subjects.json
  def create
    @course_types_subject = CourseTypesSubject.new(course_types_subject_params)

    respond_to do |format|
      if @course_types_subject.save
        format.html { redirect_to @course_types_subject, notice: 'Course types subject was successfully created.' }
        format.json { render action: 'show', status: :created, location: @course_types_subject }
      else
        format.html { render action: 'new' }
        format.json { render json: @course_types_subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /course_types_subjects/1
  # PATCH/PUT /course_types_subjects/1.json
  def update
    respond_to do |format|
      if @course_types_subject.update(course_types_subject_params)
        format.html { redirect_to @course_types_subject, notice: 'Course types subject was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @course_types_subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /course_types_subjects/1
  # DELETE /course_types_subjects/1.json
  def destroy
    @course_types_subject.destroy
    respond_to do |format|
      format.html { redirect_to course_types_subjects_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course_types_subject
      @course_types_subject = CourseTypesSubject.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_types_subject_params
      params.require(:course_types_subject).permit(:course_type_id, :subject_id)
    end
end
