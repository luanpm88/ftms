class DiscountProgramsController < ApplicationController
  include DiscountProgramsHelper
  
  load_and_authorize_resource
  
  before_action :set_discount_program, only: [:show, :edit, :update, :destroy]

  # GET /discount_programs
  # GET /discount_programs.json
  def index
    @discount_programs = DiscountProgram.all
  end

  # GET /discount_programs/1
  # GET /discount_programs/1.json
  def show
  end

  # GET /discount_programs/new
  def new
    @discount_program = DiscountProgram.new
  end

  # GET /discount_programs/1/edit
  def edit
  end

  # POST /discount_programs
  # POST /discount_programs.json
  def create
    @discount_program = DiscountProgram.new(discount_program_params)
    @discount_program.user = current_user

    respond_to do |format|
      if @discount_program.save
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @discount_program, notice: 'Discount program was successfully created.' }
        format.json { render action: 'show', status: :created, location: @discount_program }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @discount_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /discount_programs/1
  # PATCH/PUT /discount_programs/1.json
  def update
    @discount_program.user = current_user
    
    respond_to do |format|
      if @discount_program.update(discount_program_params)
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @discount_program, notice: 'Discount program was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @discount_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /discount_programs/1
  # DELETE /discount_programs/1.json
  def destroy
    @discount_program.destroy
    respond_to do |format|
      format.html { redirect_to discount_programs_url }
      format.json { head :no_content }
    end
  end
  
  def datatable
    result = DiscountProgram.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_discount_program_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_discount_program
      @discount_program = DiscountProgram.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def discount_program_params
      params.require(:discount_program).permit(:name, :user_id, :start_at, :end_at, :rate)
    end
end
