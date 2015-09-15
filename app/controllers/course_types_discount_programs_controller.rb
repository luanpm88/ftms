class CourseTypesDiscountProgramsController < ApplicationController
  before_action :set_course_types_discount_program, only: [:show, :edit, :update, :destroy]

  # GET /course_types_discount_programs
  # GET /course_types_discount_programs.json
  def index
    @course_types_discount_programs = CourseTypesDiscountProgram.all
  end

  # GET /course_types_discount_programs/1
  # GET /course_types_discount_programs/1.json
  def show
  end

  # GET /course_types_discount_programs/new
  def new
    @course_types_discount_program = CourseTypesDiscountProgram.new
  end

  # GET /course_types_discount_programs/1/edit
  def edit
  end

  # POST /course_types_discount_programs
  # POST /course_types_discount_programs.json
  def create
    @course_types_discount_program = CourseTypesDiscountProgram.new(course_types_discount_program_params)

    respond_to do |format|
      if @course_types_discount_program.save
        format.html { redirect_to @course_types_discount_program, notice: 'Course types discount program was successfully created.' }
        format.json { render action: 'show', status: :created, location: @course_types_discount_program }
      else
        format.html { render action: 'new' }
        format.json { render json: @course_types_discount_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /course_types_discount_programs/1
  # PATCH/PUT /course_types_discount_programs/1.json
  def update
    respond_to do |format|
      if @course_types_discount_program.update(course_types_discount_program_params)
        format.html { redirect_to @course_types_discount_program, notice: 'Course types discount program was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @course_types_discount_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /course_types_discount_programs/1
  # DELETE /course_types_discount_programs/1.json
  def destroy
    @course_types_discount_program.destroy
    respond_to do |format|
      format.html { redirect_to course_types_discount_programs_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course_types_discount_program
      @course_types_discount_program = CourseTypesDiscountProgram.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_types_discount_program_params
      params.require(:course_types_discount_program).permit(:course_type_id, :discount_program_id)
    end
end
