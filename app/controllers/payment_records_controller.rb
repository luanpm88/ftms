class PaymentRecordsController < ApplicationController
  include PaymentRecordsHelper
  
  load_and_authorize_resource
  
  before_action :set_payment_record, only: [:show, :edit, :update, :destroy]

  # GET /payment_records
  # GET /payment_records.json
  def index
    @payment_records = PaymentRecord.all
  end

  # GET /payment_records/1
  # GET /payment_records/1.json
  def show
  end

  # GET /payment_records/new
  def new
    @payment_record = PaymentRecord.new
    @course_register = CourseRegister.find(params[:course_register_id])
    @payment_record.course_register = @course_register
    
    @payment_record.payment_date = Time.now.strftime("%d-%b-%Y")
    @payment_record.debt_date = Time.now.strftime("%d-%b-%Y")
    
    @payment_record.amount = @course_register.remain_amount
  end

  # GET /payment_records/1/edit
  def edit
  end

  # POST /payment_records
  # POST /payment_records.json
  def create
    @payment_record = PaymentRecord.new(payment_record_params)
    @payment_record.user = current_user
    @payment_record.status = 1

    respond_to do |format|
      if @payment_record.save
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @payment_record, notice: 'Payment record was successfully created.' }
        format.json { render action: 'show', status: :created, location: @payment_record }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @payment_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payment_records/1
  # PATCH/PUT /payment_records/1.json
  def update
    respond_to do |format|
      if @payment_record.update(payment_record_params)
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @payment_record, notice: 'Payment record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @payment_record.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def datatable
    result = PaymentRecord.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_payment_record_actions(item)      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end

  # DELETE /payment_records/1
  # DELETE /payment_records/1.json
  def destroy
    @payment_record.destroy
    respond_to do |format|
      format.html { redirect_to payment_records_url }
      format.json { head :no_content }
    end
  end
  
  def print
    render  :pdf => "payment_"+@payment_record.payment_date.strftime("%d_%b_%Y"),
            :template => 'payment_records/print.pdf.erb',
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_record
      @payment_record = PaymentRecord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_record_params
      params.require(:payment_record).permit(:payment_date, :course_register_id, :amount, :debt_date, :user_id, :note)
    end
end
