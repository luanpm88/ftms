class CoursesController < ApplicationController
  include CoursesHelper
  
  load_and_authorize_resource
  
  before_action :set_course, only: [:delete, :show, :edit, :update, :destroy] # [delete] for revision-feature

  # GET /courses
  # GET /courses.json
  def index
    @courses = Course.all_courses
    
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
    @course.intake = Time.now.beginning_of_month
    @course.for_exam_year = Time.now.year
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
    @course.intake = "1990-01-01".to_date if @course.upfront
    
    respond_to do |format|
      if @course.save
        @course.update_courses_phrases(params[:courses_phrases]) if !params[:courses_phrases].nil?
        @course.update_course_prices(params[:course_prices]) if !params[:course_prices].nil?
        
        @course.update_status("create", current_user)        
        @course.save_draft(current_user)
        
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
    @course.update_program_paper(params[:program_paper])
    @course.intake = "1990-01-01".to_date if @course.upfront
    
    respond_to do |format|
      if @course.save        
        @course.update_courses_phrases(params[:courses_phrases]) if !params[:courses_phrases].nil?
        @course.update_course_prices(params[:course_prices]) if !params[:course_prices].nil?
        
        @course.update_status("update", current_user)        
        @course.save_draft(current_user)
        
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
  
  def courses_phrases_checkboxs
    if !params[:id].present?
      render nothing: true
    else
      @course = Course.find(params[:id])
      render layout: nil
    end
    
  end
  
  def course_price_select
    if !params[:id].present?
      render nothing: true
    else
      @course = Course.find(params[:id])
      render layout: nil
    end
  end
  
  
  ########## BEGIN REVISION ###############
  
  def approve_new
    authorize! :approve_new, @course
    
    @course.approve_new(current_user)
    
    respond_to do |format|
      format.html { redirect_to params[:tab_page].present? ? "/courses/approved" : @contact }
      format.json { render action: 'show', status: :created, location: @subject }
    end
  end
  
  def approve_update
    authorize! :approve_update, @course
    
    @course.approve_update(current_user)
    
    respond_to do |format|
      format.html { redirect_to params[:tab_page].present? ? "/courses/approved" : @course }
      format.json { render action: 'show', status: :created, location: @course }
    end
  end
  
  def approve_delete
    authorize! :approve_delete, @course
    
    @course.approve_delete(current_user)
    
    respond_to do |format|
      format.html { redirect_to params[:tab_page].present? ? "/courses/approved" : @course }
      format.json { render action: 'show', status: :created, location: @course }
    end
  end
  
  def approved
    render layout: "content"
  end
  
  def field_history
    @drafts = @course.field_history(params[:type])
    
    render layout: nil
  end

  def delete
    
    respond_to do |format|
      if @course.delete
        @course.save_draft(current_user)
        
        format.html { redirect_to "/home/close_tab" }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end
  
  ########## BEGIN REVISION ###############
  
  def course_phrases_form
    @course = params[:course_id].present? ? Course.find(params[:course_id]) : Course.new
    @phrases = Phrase.active_phrases.includes(:subjects).where(subjects: {id: params[:value].split("_")[1]})
    render layout: nil
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_params
      params.require(:course).permit(:upfront, :for_exam_year, :for_exam_month, :lecturer_id, :description, :user_id, :intake, :course_type_id, :course_type_ids => [])
    end
end
