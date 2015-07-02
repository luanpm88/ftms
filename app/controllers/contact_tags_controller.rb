class ContactTagsController < ApplicationController
  before_action :set_contact_tag, only: [:show, :edit, :update, :destroy]

  # GET /contact_tags
  # GET /contact_tags.json
  def index
    @contact_tags = ContactTag.all
    respond_to do |format|
      format.html
      format.json {
        render json: ContactTag.full_text_search(params[:q])
      }
    end
  end

  # GET /contact_tags/1
  # GET /contact_tags/1.json
  def show
  end

  # GET /contact_tags/new
  def new
    @contact_tag = ContactTag.new
  end

  # GET /contact_tags/1/edit
  def edit
  end

  # POST /contact_tags
  # POST /contact_tags.json
  def create
    @contact_tag = ContactTag.new(contact_tag_params)

    respond_to do |format|
      if @contact_tag.save
        format.html { redirect_to @contact_tag, notice: 'Contact tag was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contact_tag }
      else
        format.html { render action: 'new' }
        format.json { render json: @contact_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contact_tags/1
  # PATCH/PUT /contact_tags/1.json
  def update
    respond_to do |format|
      if @contact_tag.update(contact_tag_params)
        format.html { redirect_to @contact_tag, notice: 'Contact tag was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @contact_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contact_tags/1
  # DELETE /contact_tags/1.json
  def destroy
    @contact_tag.destroy
    respond_to do |format|
      format.html { redirect_to contact_tags_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact_tag
      @contact_tag = ContactTag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_tag_params
      params.require(:contact_tag).permit(:name, :description)
    end
end
