class BooksContactsController < ApplicationController
  before_action :set_books_contact, only: [:show, :edit, :update, :destroy]

  # GET /books_contacts
  # GET /books_contacts.json
  def index
    @books_contacts = BooksContact.all
  end

  # GET /books_contacts/1
  # GET /books_contacts/1.json
  def show
  end

  # GET /books_contacts/new
  def new
    @books_contact = BooksContact.new
  end

  # GET /books_contacts/1/edit
  def edit
  end

  # POST /books_contacts
  # POST /books_contacts.json
  def create
    @books_contact = BooksContact.new(books_contact_params)

    respond_to do |format|
      if @books_contact.save
        format.html { redirect_to @books_contact, notice: 'Books contact was successfully created.' }
        format.json { render action: 'show', status: :created, location: @books_contact }
      else
        format.html { render action: 'new' }
        format.json { render json: @books_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books_contacts/1
  # PATCH/PUT /books_contacts/1.json
  def update
    respond_to do |format|
      if @books_contact.update(books_contact_params)
        format.html { redirect_to @books_contact, notice: 'Books contact was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @books_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books_contacts/1
  # DELETE /books_contacts/1.json
  def destroy
    @books_contact.destroy
    respond_to do |format|
      format.html { redirect_to books_contacts_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_books_contact
      @books_contact = BooksContact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def books_contact_params
      params.require(:books_contact).permit(:course_register_id, :book_id, :contact_id, :price, :discount_program_id, :discount, :volumn_ids)
    end
end