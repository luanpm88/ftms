class Transfer < ActiveRecord::Base
  include PgSearch
  
  belongs_to :contact
  belongs_to :user
  
  belongs_to :transferred_contact, class_name: "Contact", foreign_key: "transfer_for"
  
  pg_search_scope :search,
                  against: [:money],
                  using: {
                      tsearch: {
                        dictionary: 'english',
                        any_word: true,
                        prefix: true
                      }
                  }
  
  def self.filter(params, user)
    @records = self.all
    
    if params["from_date"].present?
      @records = @records.where("transfers.transfer_date >= ?", params["from_date"].to_datetime.beginning_of_day)
    end
    if params["to_date"].present?
      @records = @records.where("transfers.transfer_date <= ?", params["to_date"].to_datetime.end_of_day)
    end
    
    if params["from_contact"].present?
      @records = @records.where(contact_id: params["from_contact"])
    end
    if params["to_contact"].present?
      @records = @records.where(transfer_for: params["to_contact"])
    end
    
    if params["contact"].present?
      @records = @records.where("transfer_for = ? OR contact_id = ?", params["contact"], params["contact"])
    end
    
    return @records
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = self.filter(params, user)
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "6"
        order = "transfers.transfer_date"
      else
        order = "transfers.transfer_date"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "transfers.transfer_date"
    end
    
    @records = @records.order(order) if !order.nil?
    
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 10
    
    
    @records.each do |item|
      
      sign = params["contact"].present? && params["contact"].to_i == item.transferred_contact.id ? "+" : ""
      item = [
              '<div class="text-center">'+item.contact.contact_link+"</div>",
              '<div class="text-center">'+item.transferred_contact.contact_link+"</div>",              
              '<div class="text-left">'+item.transfer_date.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-left">'+item.description+"</div>",
              '<div class="text-center">'+sign.to_s+item.hour.to_s+"</div>",
              '<div class="text-right">'+sign.to_s+ApplicationController.helpers.format_price(item.money)+"</div>",
              '<div class="text-right">'+sign.to_s+ApplicationController.helpers.format_price(item.admin_fee.to_f)+"</div>",
              '<div class="text-right">'+sign.to_s+ApplicationController.helpers.format_price(item.total)+"</div>",
              '<div class="text-center">'+item.created_at.strftime("%d-%b-%Y <br/> %I:%M %p").html_safe+"</div>",
              '<div class="text-center">'+item.contact.account_manager.staff_col+"</div>",
              ""
              #'<div class="text-center">'+item.programs_name+"</div>",
              #'<div class="text-center">'+item.created_at.strftime("%Y-%m-%d")+"</div>",              
              #'<div class="text-center">'+item.user.staff_col+"</div>",
              #"", 
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
  
  def total
    money - admin_fee.to_f
  end
  
  def money=(new)
    self[:money] = new.to_s.gsub(/\,/, '')
  end
  def admin_fee=(new)
    self[:admin_fee] = new.to_s.gsub(/\,/, '')
  end
  
  def courses_phrases
    cp_ids = self.courses_phrase_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
    return CoursesPhrase.where(id: cp_ids).includes(:course).order("courses.intake, start_at")
  end
  
  def courses_phrase_ids=(ids)
    self[:courses_phrase_ids] = "["+(ids.map {|s| s.strip.to_i}).join("][")+"]"
  end
  
  def description
    arr = []
    group_name = ""
    course_name = ""
    courses_phrases.each do |p|
      
      if course_name != p.course.display_name
        arr << "</div>" if course_name != ""
        arr << "<div><strong>"+p.course.display_name+"</strong></div><div class=\"courses_phrases_list\">"
        course_name = p.course.display_name
      end
      
      if group_name != p.name
        arr << "<div><strong class=\"width100\">#{p.phrase.name}</strong></div>"
        group_name = p.name
      end
      arr << "[#{p.start_at.strftime("%d-%b-%Y")}] "
    end
    return "<div>"+arr.join("").html_safe+"</div></div>"
  end
  
end
