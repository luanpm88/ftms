class DeliveriesController < ApplicationController
  load_and_authorize_resource
  
  before_action :set_delivery, only: [:trash, :pdf, :show, :edit, :update, :destroy]

  # GET /deliveries
  # GET /deliveries.json
  def index
    @deliveries = Delivery.all
  end

  # GET /deliveries/1
  # GET /deliveries/1.json
  def show
    
    #render layout: "none"
  end

  # GET /deliveries/new
  def new
    @course_register = CourseRegister.find(params[:course_register_id])
    @delivery = Delivery.new
    @delivery.course_register_id = @course_register.id
    @delivery.delivery_date = Time.now
  end

  # GET /deliveries/1/edit
  def edit
  end

  # POST /deliveries
  # POST /deliveries.json
  def create
    @delivery = Delivery.new(delivery_params)
    @delivery.user = current_user
    @delivery.status = 1
    
   @delivery.update_deliveries(params[:delivery_details])

    respond_to do |format|
      if @delivery.save
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @delivery, notice: 'Delivery was successfully created.' }
        format.json { render action: 'show', status: :created, location: @delivery }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /deliveries/1
  # PATCH/PUT /deliveries/1.json
  def update
    respond_to do |format|
      if @delivery.update(delivery_params)
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @delivery, notice: 'Delivery was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deliveries/1
  # DELETE /deliveries/1.json
  def destroy
    @delivery.destroy
    respond_to do |format|
      format.html { redirect_to deliveries_url }
      format.json { head :no_content }
    end
  end
  
  def print
    authorize! :delivery_print, @delivery.course_register
    
    render  :pdf => "delivery_"+@delivery.delivery_date.strftime("%d_%b_%Y"),
            :template => 'deliveries/print.pdf.erb',
            :layout => nil,
            :footer => {
               :center => "",
               :left => "",
               :right => "",
               :page_size => "A4",
               :margin  => {:top    => 0, # default 10 (mm)
                          :bottom => 0,
                          :left   => 0,
                          :right  => 0},
            }
  end
  
  def delivery_list
    @bc_list = BooksContact.all_delivery_waiting
    
    respond_to do |format|
      format.html
      format.xls
    end
  end
  
  def trash
    @delivery.trash
    
    respond_to do |format|
      format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : deliveries_path, notice: 'Delivery was successfully updated.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery
      @delivery = Delivery.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def delivery_params
      params.require(:delivery).permit(:course_register_id, :contact_id, :delivery_date, :user_id)
    end
end
