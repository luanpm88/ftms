class CourseType < ActiveRecord::Base
  include PgSearch
  
  validates :name, :presence => true, :uniqueness => true
  validates :short_name, :presence => true, :uniqueness => true
  
  belongs_to :user
  
  has_many :courses
  
  has_and_belongs_to_many :subjects
  
  pg_search_scope :search,
                  against: [:name, :short_name, :description],                
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
      when "0"
        order = "course_types.name"
      when "1"
        order = "course_types.short_name"
      when "2"
        order = "course_types.created_at"
      else
        order = "course_types.name"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "course_types.name"
    end
    
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 4
    @records.each do |item|
      item = [
              item.short_name,
              item.name,
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
  
  def self.full_text_search(q)
    self.search(q).limit(50).map {|model| {:id => model.id, :text => model.short_name} }
  end
  
  
end
