class SubjectsController < ApplicationController
  include SubjectsHelper
  
  load_and_authorize_resource
  
  before_action :set_subject, only: [:show, :edit, :update, :destroy]

  # GET /subjects
  # GET /subjects.json
  def index
    @subjects = Subject.all
  end

  # GET /subjects/1
  # GET /subjects/1.json
  def show
  end

  # GET /subjects/new
  def new
    @subject = Subject.new
  end

  # GET /subjects/1/edit
  def edit
  end

  # POST /subjects
  # POST /subjects.json
  def create
    @subject = Subject.new(subject_params)
    @subject.user = current_user

    respond_to do |format|
      if @subject.save
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @subject, notice: 'Subject was successfully created.' }
        format.json { render action: 'show', status: :created, location: @subject }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subjects/1
  # PATCH/PUT /subjects/1.json
  def update
    respond_to do |format|
      if @subject.update(subject_params)
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @subject, notice: 'Subject was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.json
  def destroy
    @subject.destroy
    respond_to do |format|
      format.html { redirect_to subjects_url(tab_page: 1) }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = Subject.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_subject_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subject
      @subject = Subject.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subject_params
      params.require(:subject).permit(:name, :description)
    end
end
