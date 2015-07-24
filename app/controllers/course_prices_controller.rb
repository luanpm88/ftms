class CoursePricesController < ApplicationController
  before_action :set_course_price, only: [:show, :edit, :update, :destroy]

  # GET /course_prices
  # GET /course_prices.json
  def index
    @course_prices = CoursePrice.all
  end

  # GET /course_prices/1
  # GET /course_prices/1.json
  def show
  end

  # GET /course_prices/new
  def new
    @course_price = CoursePrice.new
  end

  # GET /course_prices/1/edit
  def edit
  end

  # POST /course_prices
  # POST /course_prices.json
  def create
    @course_price = CoursePrice.new(course_price_params)

    respond_to do |format|
      if @course_price.save
        format.html { redirect_to @course_price, notice: 'Course price was successfully created.' }
        format.json { render action: 'show', status: :created, location: @course_price }
      else
        format.html { render action: 'new' }
        format.json { render json: @course_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /course_prices/1
  # PATCH/PUT /course_prices/1.json
  def update
    respond_to do |format|
      if @course_price.update(course_price_params)
        format.html { redirect_to @course_price, notice: 'Course price was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @course_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /course_prices/1
  # DELETE /course_prices/1.json
  def destroy
    @course_price.destroy
    respond_to do |format|
      format.html { redirect_to course_prices_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course_price
      @course_price = CoursePrice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_price_params
      params.require(:course_price).permit(:course_id, :prices, :user_id)
    end
end
