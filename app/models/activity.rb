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
  
  def self.main_activities
    self.where(deleted: 0)
  end
  
  def self.filter(params, user)
    @records = self.all
    @records = @records.where(contact_id: params[:contact_id]) if params[:contact_id].present?
    
    if params[:status].present?
      @records = @records.where(deleted: params[:status])
    end    
    
    return @records
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    
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
    
    actions_col = 4
    @records.each do |item|
      item = [
              item.note.gsub("\n","<br />").html_safe,
              "<div class=\"text-center nowrap\">#{item.created_at.strftime("%d-%b-%Y, %I:%M %p")}</div>",
              "<div class=\"text-center\">#{item.user.staff_col}</div>",
              "<div class=\"text-center\">#{item.display_statuses}</div>",  
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
  
  def delete
    self.update_attribute(:deleted, 1) if self.deleted == 0
  end
  
  def display_statuses
    s = deleted == 1 ? "deleted" : "active"
    result = "<span title=\"\" class=\"badge user-role badge-info contact-status #{s}\">#{s}</span>"
    return result
  end
  
  def self.status_options
    [      
      ["Active",0],
      ["Deleted",1],
      ["All",""],
    ]
  end

end
