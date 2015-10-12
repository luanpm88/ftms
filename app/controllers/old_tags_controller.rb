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

end
