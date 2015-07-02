class ContactTagsContactsController < ApplicationController
  before_action :set_contact_tags_contact, only: [:show, :edit, :update, :destroy]

  # GET /contact_tags_contacts
  # GET /contact_tags_contacts.json
  def index
    @contact_tags_contacts = ContactTagsContact.all
  end

  # GET /contact_tags_contacts/1
  # GET /contact_tags_contacts/1.json
  def show
  end

  # GET /contact_tags_contacts/new
  def new
    @contact_tags_contact = ContactTagsContact.new
  end

  # GET /contact_tags_contacts/1/edit
  def edit
  end

  # POST /contact_tags_contacts
  # POST /contact_tags_contacts.json
  def create
    @contact_tags_contact = ContactTagsContact.new(contact_tags_contact_params)

    respond_to do |format|
      if @contact_tags_contact.save
        format.html { redirect_to @contact_tags_contact, notice: 'Contact tags contact was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contact_tags_contact }
      else
        format.html { render action: 'new' }
        format.json { render json: @contact_tags_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contact_tags_contacts/1
  # PATCH/PUT /contact_tags_contacts/1.json
  def update
    respond_to do |format|
      if @contact_tags_contact.update(contact_tags_contact_params)
        format.html { redirect_to @contact_tags_contact, notice: 'Contact tags contact was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @contact_tags_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contact_tags_contacts/1
  # DELETE /contact_tags_contacts/1.json
  def destroy
    @contact_tags_contact.destroy
    respond_to do |format|
      format.html { redirect_to contact_tags_contacts_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact_tags_contact
      @contact_tags_contact = ContactTagsContact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_tags_contact_params
      params.require(:contact_tags_contact).permit(:contact_id, :contact_type_id, :user_id)
    end
end
