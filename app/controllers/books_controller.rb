class BooksController < ApplicationController
  include BooksHelper
  
  before_action :set_book, only: [:cover, :show, :edit, :update, :destroy]
  
  load_and_authorize_resource :except => [:cover]

  # GET /books
  # GET /books.json
  def index
    @books = Book.all
    
    respond_to do |format|
      format.html
      format.json {
        render json: Book.full_text_search(params)
      }
    end
  end

  # GET /books/1
  # GET /books/1.json
  def show
  end

  # GET /books/new
  def new
    @book = Book.new
    
    if params[:parent_id]
      @book.parent = Book.find(params[:parent_id])
    end
    
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books
  # POST /books.json
  def create
    @book = Book.new(book_params)
    @book.user = current_user

    respond_to do |format|
      if @book.save
        new_price = @book.book_prices.new(prices: params[:book_prices], user_id: current_user.id)
        @book.update_price(new_price)
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @book, notice: 'Book was successfully created.' }
        format.json { render action: 'show', status: :created, location: @book }
      else
        format.html { render action: 'new', tab_page: params[:tab_page] }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        new_price = @book.book_prices.new(prices: params[:book_prices], user_id: current_user.id)
        @book.update_price(new_price)
        
        format.html { redirect_to params[:tab_page].present? ? "/home/close_tab" : @book, notice: 'Book was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit', tab_page: params[:tab_page] }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    @book.destroy
    respond_to do |format|
      format.html { redirect_to books_url }
      format.json { head :no_content }
    end
  end
  
  def cover
    send_file @book.cover_path(params[:type]), :disposition => 'inline'
  end
  
  def datatable
    result = Book.datatable(params, current_user)
    
    result[:items].each_with_index do |item, index|
      actions = render_book_actions(item)
      
      result[:result]["data"][index][result[:actions_col]] = actions
    end
    
    render json: result[:result]
  end
  
  def student_books
    result = Book.student_books(params, current_user)
    
    #result[:items].each_with_index do |item, index|
    #  actions = render_book_actions(item)
    #  
    #  result[:result]["data"][index][result[:actions_col]] = actions
    #end
    
    render json: result[:result]
  end
  
  def stock_select
    @books = Book.filter(params, current_user)    
    
    render layout: nil
  end
  
  def volumn_checkboxs
    if !params[:id].present?
      render nothing: true
    else
      @books = Book.find(params[:id])
      render layout: nil
    end   
  end
  
  def stock_price_form
    if !params[:id].present?
      render nothing: true
    else
      @books = Book.find(params[:id])
      render layout: nil
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_params
      params.require(:book).permit(:subject_ids, :course_type_ids, :name, :description, :user_id, :image, :pirce, :publisher, :parent_id)
    end
end
