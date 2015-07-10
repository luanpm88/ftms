class CourseTypesController < ApplicationController
  include CourseTypesHelper
  load_and_authorize_resource
  
  before_action :set_course_type, only: [:show, :edit, :update, :destroy]

  # GET /course_types
  # GET /course_types.json
  def index
    @course_types = CourseType.all
    
    respond_to do |format|
      format.html { render layout: "content" if params[:tab_page].present? }
      format.json {
        render json: CourseType.full_text_search(params[:q])
      }
    end
    
  end

  # GET /course_types/1
  # GET /course_types/1.json
  def show
  end

  # GET /course_types/new
  def new
    @course_type = CourseType.new
  end

  # GET /course_types/1/edit
  def edit
  end

  # POST /course_types
  # POST /course_types.json
  def create
    @course_type = CourseType.new(course_type_params)
    @course_type.user = current_user

    respond_to do |format|
      if @course_type.save
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : course_types_path, notice: 'Course type was successfully created.' }
        format.json { render action: 'show', status: :created, location: @course_type }
      else
        format.html { render action: 'new', tab_page: params[:tab_page]}
        format.json { render json: @course_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /course_types/1
  # PATCH/PUT /course_types/1.json
  def update
    respond_to do |format|
      if @course_type.update(course_type_params)
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : course_types_path, notice: 'Course type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @course_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /course_types/1
  # DELETE /course_types/1.json
  def destroy
    @course_type.destroy
    respond_to do |format|
      format.html { redirect_to course_types_url(tab_page: 1), notice: 'Course type was successfully deleted.' }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = CourseType.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_course_type_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course_type
      @course_type = CourseType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_type_params
      params.require(:course_type).permit(:name, :short_name, :description)
    end
end