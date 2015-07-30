class Activity < ActiveRecord::Base
  validates :note, presence: true
  
  include PgSearch
  
  belongs_to :contact
  belongs_to :user
  
  pg_search_scope :search,
                  against: [:note],
                  associated_against: {
                    user: [:first_name, :last_name],
                    contact: [:name]
                  },
                  using: {
                      tsearch: {
                        dictionary: 'english',
                        any_word: true,
                        prefix: true
                      }
                  }
  
  def self.filter(params, user)
    @records = self.all
    @records = @records.where(contact_id: params[:contact_id]) if params[:contact_id].present?
    
    return @records
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = self.filter(params, user)
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "0"
        order = "activities.created_at"
      else
        order = "activities.created_at"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "activities.created_at DESC"
    end
    
    @records = @records.order(order) if !order.nil?
    
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 3
    @records.each do |item|
      item = [
              item.note.gsub("\n","<br />").html_safe,
              "<div class=\"text-center nowrap\">#{item.created_at.strftime("%d-%b-%Y, %I:%M %p")}</div>",
              "<div class=\"text-center\">#{item.user.staff_col}</div>",            
              ""
            ]
      data << item
      
    end
    
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => total
    }
    result["data"] = data
    
    return {result: result, items: @records, actions_col: actions_col}
    
  end

end
