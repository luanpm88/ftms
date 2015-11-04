class HomeController < ApplicationController
  def index
    #code
  end
  
  def main_menu
    render layout: nil
  end
  
  def close_tab
    if params[:contact_id].present?
      @contact = Contact.find(params[:contact_id])
    end
    
    render layout: nil
  end
end
