class UserLog < ActiveRecord::Base
  belongs_to :user
  
  
  include PgSearch
  pg_search_scope :search,
                  against: [:content],                  
                  using: {
                      tsearch: {
                        dictionary: 'english',
                        any_word: true,
                        prefix: true
                      }
                  }
                  
  def self.datatable(params, user)
 
    @records = self.all
    
    if params["user"].present?
      @records = @records.where(user_id: params["user"])
    end
    
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    order = "activities.created_at DESC"
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "user_logs.created_at"
      else
        order = "user_logs.created_at"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "user_logs.created_at DESC"
    end    
    @records = @records.order(order) if !order.nil?    
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 3
    @records.each do |item|
      item = [
              "<div class=\"text-left\">#{item.title}</div>",
              "<div class=\"text-content\">#{item.content}</div>",
              "<div class=\"text-center nowrap\">#{item.created_at.strftime("%d-%b-%Y, %I:%M %p")}</div>",
              "<div class=\"text-center\">#{item.user.staff_col}</div>"
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
  
  def render_content(contacts, params)
      # User Log
      @contacts = contacts
      str = []
      
      str << "Number of Contacts: #{@contacts.count.to_s}"
      str << "Search Keyword: #{params["datatable_search_keyword"]}" if params["datatable_search_keyword"].present?
      
      str << "Kind of Contacts: " + (params[:is_individual] == "false" ? "Company/Organization" : "Individual")
      str << "Contact Type: #{(ContactType.find(params[:contact_types])).map(&:name).join(", ")}" if params[:contact_types].present?
      str << "Intake: #{params["filter"]["intake(1i)"]}/#{params["filter"]["intake(2i)"]}" if params["filter"]["intake(1i)"].present? || params["filter"]["intake(2i)"].present?
      str << "Course Type: #{(CourseType.find(params[:course_types])).map(&:short_name).join(", ")}" if params[:course_types].present?
      str << "Status: #{params[:base_status]}" if params[:base_status].present?
      str << "Paper: #{(Subject.find(params[:subjects])).map(&:name).join(", ")}" if params[:subjects].present?
      str << "Seminar: #{(Seminar.find(params[:seminars])).name}" if params[:seminars].present?
      str << "Course: #{(Course.find(params[:courses])).display_name}" if params[:courses].present?
      str << "Phrase: #{(Phrase.find(params[:phrases].split(","))).map(&:name).join(", ")}" if params[:phrases].present?
      str << "Created on: #{params[:created_from]} -> #{params[:created_to]}" if params[:created_from].present? or params[:created_to].present?
      str << "Payment Type: #{params[:payment_type]}" if params[:payment_type].present?
      str << "Company: #{(Contact.find(params[:company])).display_name}" if params[:company].present?
      str << "EC: #{(User.find(params[:user])).name}" if params[:user].present?
      str << "Approve Status: #{params[:status]}" if params[:status].present?
      str << "Tag: #{(ContactTag.find(params[:tags])).map(&:name).join(", ")}" if params[:tags].present?
      str << "Olg Tag: #{(OldTag.where(tag_name: params[:old_tag])).first.tag_name}" if params[:old_tag].present?
      str << "Olg Course: #{(OldLinkStudent.where(subject_id: params[:old_course])).first.subject_id}" if params[:old_course].present?
      
      str << 
      
      self.content = str.join("<br />")
  end
                  
end
