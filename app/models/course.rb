class Course < ActiveRecord::Base
  include PgSearch
  
  validates :course_type, :presence => true
  
  belongs_to :user
  belongs_to :course_type
  
  pg_search_scope :search,
                  against: [:description],
                  associated_against: {
                    course_type: [:name, :short_name]
                  },
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
    
    @records = self.joins(:course_type)
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    @records = @records.where("EXTRACT(YEAR FROM courses.intake) = ? ", params["intake_year"]) if params["intake_year"].present?
    @records = @records.where("EXTRACT(MONTH FROM courses.intake) = ? ", params["intake_month"]) if params["intake_month"].present?
    @records = @records.where("courses.course_type_id IN (#{params["course_types"]})") if params["course_types"].present?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "0"
        order = "courses.intake"
      when "1"
        order = "course_types.short_name"
      when "3"
        order = "courses.created_at"
      else
        order = "courses.created_at"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "courses.intake DESC"
    end
    
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 5
    @records.each do |item|
      item = [
              item.display_intake,
              item.course_type.short_name,
              item.description,
              '<div class="text-center">'+item.created_at.strftime("%Y-%m-%d")+"</div>",
              '<div class="text-center">'+item.user.staff_col+"</div>",
              "", 
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
  
  def name
    intake.year.to_s+"/"+Date::MONTHNAMES[intake.month]+"/"+course_type.short_name
  end
  
  def display_intake
    Date::MONTHNAMES[intake.month]+", "+intake.year.to_s
  end
  
end
