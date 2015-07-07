class ContactsCoursesController < ApplicationController
  before_action :set_contacts_course, only: [:show, :edit, :update, :destroy]

  # GET /contacts_courses
  # GET /contacts_courses.json
  def index
    @contacts_courses = ContactsCourse.all
  end

  # GET /contacts_courses/1
  # GET /contacts_courses/1.json
  def show
  end

  # GET /contacts_courses/new
  def new
    @contacts_course = ContactsCourse.new
  end

  # GET /contacts_courses/1/edit
  def edit
  end

  # POST /contacts_courses
  # POST /contacts_courses.json
  def create
    @contacts_course = ContactsCourse.new(contacts_course_params)

    respond_to do |format|
      if @contacts_course.save
        format.html { redirect_to @contacts_course, notice: 'Contacts course was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contacts_course }
      else
        format.html { render action: 'new' }
        format.json { render json: @contacts_course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts_courses/1
  # PATCH/PUT /contacts_courses/1.json
  def update
    respond_to do |format|
      if @contacts_course.update(contacts_course_params)
        format.html { redirect_to @contacts_course, notice: 'Contacts course was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @contacts_course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts_courses/1
  # DELETE /contacts_courses/1.json
  def destroy
    @contacts_course.destroy
    respond_to do |format|
      format.html { redirect_to contacts_courses_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contacts_course
      @contacts_course = ContactsCourse.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contacts_course_params
      params.require(:contacts_course).permit(:contact_id, :course_id, :course_register_id)
    end
end
