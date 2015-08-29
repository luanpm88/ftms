class TransferDetailsController < ApplicationController
  before_action :set_transfer_detail, only: [:show, :edit, :update, :destroy]

  # GET /transfer_details
  # GET /transfer_details.json
  def index
    @transfer_details = TransferDetail.all
  end

  # GET /transfer_details/1
  # GET /transfer_details/1.json
  def show
  end

  # GET /transfer_details/new
  def new
    @transfer_detail = TransferDetail.new
  end

  # GET /transfer_details/1/edit
  def edit
  end

  # POST /transfer_details
  # POST /transfer_details.json
  def create
    @transfer_detail = TransferDetail.new(transfer_detail_params)

    respond_to do |format|
      if @transfer_detail.save
        format.html { redirect_to @transfer_detail, notice: 'Transfer detail was successfully created.' }
        format.json { render action: 'show', status: :created, location: @transfer_detail }
      else
        format.html { render action: 'new' }
        format.json { render json: @transfer_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transfer_details/1
  # PATCH/PUT /transfer_details/1.json
  def update
    respond_to do |format|
      if @transfer_detail.update(transfer_detail_params)
        format.html { redirect_to @transfer_detail, notice: 'Transfer detail was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @transfer_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transfer_details/1
  # DELETE /transfer_details/1.json
  def destroy
    @transfer_detail.destroy
    respond_to do |format|
      format.html { redirect_to transfer_details_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transfer_detail
      @transfer_detail = TransferDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transfer_detail_params
      params.require(:transfer_detail).permit(:transfer_id, :contacts_course_id, :courses_phrase_ids)
    end
end
