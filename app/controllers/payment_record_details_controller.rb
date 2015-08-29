class PaymentRecordDetailsController < ApplicationController
  before_action :set_payment_record_detail, only: [:show, :edit, :update, :destroy]

  # GET /payment_record_details
  # GET /payment_record_details.json
  def index
    @payment_record_details = PaymentRecordDetail.all
  end

  # GET /payment_record_details/1
  # GET /payment_record_details/1.json
  def show
  end

  # GET /payment_record_details/new
  def new
    @payment_record_detail = PaymentRecordDetail.new
  end

  # GET /payment_record_details/1/edit
  def edit
  end

  # POST /payment_record_details
  # POST /payment_record_details.json
  def create
    @payment_record_detail = PaymentRecordDetail.new(payment_record_detail_params)

    respond_to do |format|
      if @payment_record_detail.save
        format.html { redirect_to @payment_record_detail, notice: 'Payment record detail was successfully created.' }
        format.json { render action: 'show', status: :created, location: @payment_record_detail }
      else
        format.html { render action: 'new' }
        format.json { render json: @payment_record_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payment_record_details/1
  # PATCH/PUT /payment_record_details/1.json
  def update
    respond_to do |format|
      if @payment_record_detail.update(payment_record_detail_params)
        format.html { redirect_to @payment_record_detail, notice: 'Payment record detail was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @payment_record_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_record_details/1
  # DELETE /payment_record_details/1.json
  def destroy
    @payment_record_detail.destroy
    respond_to do |format|
      format.html { redirect_to payment_record_details_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_record_detail
      @payment_record_detail = PaymentRecordDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_record_detail_params
      params.require(:payment_record_detail).permit(:contacts_course_id, :books_contact_id, :amount)
    end
end
