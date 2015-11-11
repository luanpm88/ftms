class RelatedContactsController < ApplicationController
  before_action :set_related_contact, only: [:show, :edit, :update, :destroy]

  # GET /related_contacts
  # GET /related_contacts.json
  def index
    @related_contacts = RelatedContact.all
  end

  # GET /related_contacts/1
  # GET /related_contacts/1.json
  def show
  end

  # GET /related_contacts/new
  def new
    @related_contact = RelatedContact.new
  end

  # GET /related_contacts/1/edit
  def edit
  end

  # POST /related_contacts
  # POST /related_contacts.json
  def create
    @related_contact = RelatedContact.new(related_contact_params)

    respond_to do |format|
      if @related_contact.save
        format.html { redirect_to @related_contact, notice: 'Related contact was successfully created.' }
        format.json { render action: 'show', status: :created, location: @related_contact }
      else
        format.html { render action: 'new' }
        format.json { render json: @related_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /related_contacts/1
  # PATCH/PUT /related_contacts/1.json
  def update
    respond_to do |format|
      if @related_contact.update(related_contact_params)
        format.html { redirect_to @related_contact, notice: 'Related contact was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @related_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /related_contacts/1
  # DELETE /related_contacts/1.json
  def destroy
    @related_contact.destroy
    respond_to do |format|
      format.html { redirect_to related_contacts_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_related_contact
      @related_contact = RelatedContact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def related_contact_params
      params.require(:related_contact).permit(:contact_ids)
    end
end
