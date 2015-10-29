class OldTagsController < ApplicationController
  load_and_authorize_resource :except => [:cover]

  def index
    #@books = Book.all
    
    respond_to do |format|
      format.html
      format.json {
        render json: OldTag.full_text_search(params)
      }
    end
  end
  
  # DELETE /phrases/1
  # DELETE /phrases/1.json
  def delete
    @phrase = OldTag.find(params[:id])
    @phrase.destroy
    
    render nothing: true
  end

end
