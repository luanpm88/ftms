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
                  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = self.all
    
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
    
    actions_col = 8
    @records.each do |item|
      item = [
              '<div class="text-left">'+item.transfer_date.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-left">'+item.description+"</div>",
              '<div class="text-center">'+item.hours.to_s+"</div>",
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.money)+"</div>",
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.admin_fee.to_f)+"</div>",
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.total)+"</div>",
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
