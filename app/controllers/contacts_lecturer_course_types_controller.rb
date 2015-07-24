class ContactsLecturerCourseTypesController < ApplicationController
  before_action :set_contacts_lecturer_course_type, only: [:show, :edit, :update, :destroy]

  # GET /contacts_lecturer_course_types
  # GET /contacts_lecturer_course_types.json
  def index
    @contacts_lecturer_course_types = ContactsLecturerCourseType.all
  end

  # GET /contacts_lecturer_course_types/1
  # GET /contacts_lecturer_course_types/1.json
  def show
  end

  # GET /contacts_lecturer_course_types/new
  def new
    @contacts_lecturer_course_type = ContactsLecturerCourseType.new
  end

  # GET /contacts_lecturer_course_types/1/edit
  def edit
  end

  # POST /contacts_lecturer_course_types
  # POST /contacts_lecturer_course_types.json
  def create
    @contacts_lecturer_course_type = ContactsLecturerCourseType.new(contacts_lecturer_course_type_params)

    respond_to do |format|
      if @contacts_lecturer_course_type.save
        format.html { redirect_to @contacts_lecturer_course_type, notice: 'Contacts lecturer course type was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contacts_lecturer_course_type }
      else
        format.html { render action: 'new' }
        format.json { render json: @contacts_lecturer_course_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts_lecturer_course_types/1
  # PATCH/PUT /contacts_lecturer_course_types/1.json
  def update
    respond_to do |format|
      if @contacts_lecturer_course_type.update(contacts_lecturer_course_type_params)
        format.html { redirect_to @contacts_lecturer_course_type, notice: 'Contacts lecturer course type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @contacts_lecturer_course_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts_lecturer_course_types/1
  # DELETE /contacts_lecturer_course_types/1.json
  def destroy
    @contacts_lecturer_course_type.destroy
    respond_to do |format|
      format.html { redirect_to contacts_lecturer_course_types_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contacts_lecturer_course_type
      @contacts_lecturer_course_type = ContactsLecturerCourseType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contacts_lecturer_course_type_params
      params.require(:contacts_lecturer_course_type).permit(:contact_id, :course_type_id)
    end
end
