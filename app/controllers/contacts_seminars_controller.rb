class ContactsSeminarsController < ApplicationController
  before_action :set_contacts_seminar, only: [:show, :edit, :update, :destroy]

  # GET /contacts_seminars
  # GET /contacts_seminars.json
  def index
    @contacts_seminars = ContactsSeminar.all
  end

  # GET /contacts_seminars/1
  # GET /contacts_seminars/1.json
  def show
  end

  # GET /contacts_seminars/new
  def new
    @contacts_seminar = ContactsSeminar.new
  end

  # GET /contacts_seminars/1/edit
  def edit
  end

  # POST /contacts_seminars
  # POST /contacts_seminars.json
  def create
    @contacts_seminar = ContactsSeminar.new(contacts_seminar_params)

    respond_to do |format|
      if @contacts_seminar.save
        format.html { redirect_to @contacts_seminar, notice: 'Contacts seminar was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contacts_seminar }
      else
        format.html { render action: 'new' }
        format.json { render json: @contacts_seminar.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts_seminars/1
  # PATCH/PUT /contacts_seminars/1.json
  def update
    respond_to do |format|
      if @contacts_seminar.update(contacts_seminar_params)
        format.html { redirect_to @contacts_seminar, notice: 'Contacts seminar was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @contacts_seminar.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts_seminars/1
  # DELETE /contacts_seminars/1.json
  def destroy
    @contacts_seminar.destroy
    respond_to do |format|
      format.html { redirect_to contacts_seminars_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contacts_seminar
      @contacts_seminar = ContactsSeminar.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contacts_seminar_params
      params.require(:contacts_seminar).permit(:contact_id, :seminar_id)
    end
end
