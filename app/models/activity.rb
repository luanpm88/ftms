class Activity < ActiveRecord::Base
  validates :note, presence: true
  
  
  
  include PgSearch
  
  belongs_to :contact
  belongs_to :user
  belongs_to :account_manager, class_name: "User"
  
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
  
  after_create :update_cache_search
  
  def self.main_activities
    self.where(deleted: 0)
  end
  
  def self.filter(params, user)
    @records = self.all
    @records = @records.where(contact_id: params[:contact_id]) if params[:contact_id].present?
    
    if params["from_date"].present?
      @records = @records.where("activities.created_at >= ?", params["from_date"].to_datetime.beginning_of_day)
    end
    if params["to_date"].present?
      @records = @records.where("activities.created_at <= ?", params["to_date"].to_datetime.end_of_day)
    end
    
    if params["contact"].present?
      @records = @records.where(contact_id: params["contact"])
    end
    
    if params["user"].present?
      @records = @records.where(user_id: params["user"])
    end
    
    if params[:status].present?
      @records = @records.where(deleted: params[:status])
    else
      @records = @records.where.not(deleted: 2)
    end    
    
    return @records
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    
    @records = self.filter(params, user)
    
    #@records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    @records = @records.where("LOWER(activities.cache_search) LIKE ?", "%#{params["search"]["value"].strip.downcase}%") if params["search"].present? && !params["search"]["value"].empty?
    
    order = "activities.created_at DESC"
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "2"
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
    
    actions_col = 6
    @records.each do |item|
      
      item = [
              params[:contact_id].present? ? "" : "<div item_id=\"#{item.id.to_s}\" class=\"main_part_info checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
              item.content(user),
              "<div class=\"text-center nowrap\">#{item.display_created_at}</div>",
              "<div class=\"text-center\">#{item.contact.contact_link}</div>",
              "<div class=\"text-center\">#{item.contact.account_manager.staff_col}</div>",
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
  
  def display_created_at
    date = created_at
    u = user
    if item_code.present?
      type = item_code.split("_")[0]
      code = item_code.split("_")[1]
      
      if type == "transfer"
        date = Transfer.find(code).created_at
        u = Transfer.find(code).user
      end
      if type == "registration"
        date = CourseRegister.find(code).created_at
        u = CourseRegister.find(code).user
      end
    end
    
    "#{date.strftime("%d-%b-%Y, %I:%M %p")}<br /><strong>by:</strong><br />#{u.staff_col}"
  end
  
  def content(u)
    if item_code.present?
      type = item_code.split("_")[0]
      code = item_code.split("_")[1]
      
      if type == "transfer"
        return "<span class=\"note_content\">"+Transfer.find(code).note_log(contact).html_safe+"</span>"
      end
      if type == "registration"
        return "<span class=\"note_content\">"+CourseRegister.find(code).note_log.html_safe+"</span>"
      end
    else
      edit_box = u == user ? "<a class=\"note_edit_button\" href=\"#edit\"><i class=\"icon-pencil\"></i> Edit</a><div class=\"note_log_edit_box\" item-id=\"#{id.to_s}\"><textarea class=>#{note}</textarea><br /><button class=\"btn btn-small btn-primary note_save_button\">Save</button><button class=\"btn btn-small btn-white note_cancel_button\">Cancel</button></div>" : ""
      return "<span class=\"note_content\">"+note.gsub("\n","<br />").html_safe+"</span>"+edit_box
    end
  end
  
  def staff_col
    if account_manager.nil?
      self.account_manager = contact.account_manager
      self.save
    end
    user.staff_col
  end
  
  def delete
    self.update_attribute(:deleted, 1) if self.deleted == 0
  end
  
  def display_statuses
    s = deleted == 2 ? "deleted" : (deleted == 1 ? "delete_pending" : "active")
    result = "<span title=\"\" class=\"badge user-role badge-info contact-status #{s}\">#{s}</span>"
    return result
  end
  
  def self.status_options
    [      
      ["All",""],
      ["Delete Pending",1],
      ["Deleted",2]
    ]
  end
  
  def update_cache_search
    
    str = []
    str << note.to_s
    str << note.to_s.unaccent
    str << created_at.strftime("%d-%b-%Y, %I:%M %p")
    str << contact.display_name
    str << contact.display_name.unaccent
    str << staff_col
    str << display_statuses
    
    self.update_attribute(:cache_search, str.join(" "))
  end


end
