class BooksContactsController < ApplicationController
  load_and_authorize_resource
  include BooksContactsHelper
  
  before_action :set_books_contact, only: [:delete, :upfront_book_select_box, :remove, :check_upfront, :show, :edit, :update, :destroy]

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
  
  def datatable
    result = BooksContact.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_books_contact_actions(item)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def check_upfront
    if params[:book_id].present?
      @books_contact.update_attribute(:book_id, params[:book_id])
      @books_contact.update_attribute(:upfront, false)
    else
      @books_contact.update_attribute(:upfront, true)
    end
    
    render layout: nil
  end
  
  def remove
    @books_contact.delivery_details.destroy_all
    @books_contact.update_statuses
    
    respond_to do |format|
      format.html { render "/books_contacts/deleted", layout: nil }
      format.json { render action: 'show', status: :created, location: @contact }
    end
  end

  def upfront_book_select_box
    @book = @books_contact.book
    render layout: nil
  end

  def delete
    @books_contact.delete(current_user)
    
    render text: "Stock registration was successfully removed!"
  end
  
  def delete_all
    
    if params[:ids].present?
      if !params[:check_all_page].nil?
        params[:intake_year] = params["filter"]["intake(1i)"] if params["filter"].present?
        params[:intake_month] = params["filter"]["intake(2i)"] if params["filter"].present?
        
        if params[:is_individual] == "false"
          params[:contact_types] = nil
        end        
        
        @books_contacts = BooksContact.filter(params, current_user)
      else
        @books_contacts = BooksContact.where(id: params[:ids])
      end
    end
    
    if @books_contacts.count <= 50
      @books_contacts.each do |bc|
        bc.delete(current_user)
      end
      
      render text: "Stock registration was successfully removed!"
    else
      render text: "<span class='out_of_date'>Error: Too many records!</span>"
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
