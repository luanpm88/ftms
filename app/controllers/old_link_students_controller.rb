class OldLinkStudentsController < ApplicationController
  load_and_authorize_resource :except => [:cover]

  def index
    #@books = Book.all
    
    respond_to do |format|
      format.html
      format.json {
        render json: OldLinkStudent.full_text_search(params)
      }
    end
  end

end
