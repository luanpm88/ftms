class CoursesController < ApplicationController
  include CoursesHelper
  
  load_and_authorize_resource
  
  before_action :set_course, only: [:show, :edit, :update, :destroy]

  # GET /courses
  # GET /courses.json
  def index
    @courses = Course.all
    
    if params[:student_id]
      @student = Contact.find(params[:student_id])
    end
    
    respond_to do |format|
      format.html { render layout: "content" if params[:tab_page].present? }
      format.json {
        render json: Course.full_text_search(params[:q])
      }
    end
  end

  # GET /courses/1
  # GET /courses/1.json
  def show
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
    @types = [ContactType.student.id.to_s]
    @individual_statuses = ["true"]
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new(course_params)
    @course.user = current_user    
    @course.update_program_paper(params[:program_paper])
    
    respond_to do |format|
      if @course.save        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @course, notice: 'Course was successfully created.' }
        format.json { render action: 'show', status: :created, location: @course }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1
  # PATCH/PUT /courses/1.json
  def update
    @course.assign_attributes(course_params)
    course_types_subject = @course.update_program_paper(params[:program_paper])    
    
    respond_to do |format|
      if @course.save
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @course, notice: 'Course was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to courses_url(tab_page: 1) }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = Course.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_course_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def student_courses
    result = Course.student_courses(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_student_courses_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_params
      params.require(:course).permit(:lecturer_id, :description, :user_id, :intake, :course_type_id, :course_type_ids => [])
    end
end