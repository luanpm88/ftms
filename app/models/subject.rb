class Subject < ActiveRecord::Base
  include PgSearch
  
  validates :name, :presence => true, :uniqueness => true
  
  belongs_to :user
  
  has_and_belongs_to_many :course_types
  has_and_belongs_to_many :phrases
  
  pg_search_scope :search,
                  against: [:name, :description],
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
        order = "subjects.name"
      when "2"
        order = "subjects.created_at"
      else
        order = "subjects.name"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "subjects.name"
    end
    
    @records = @records.order(order) if !order.nil?
    
    if params["course_types"].present?
      @records = @records.joins(:course_types)
      @records = @records.where("course_types.id IN (#{params["course_types"].join(",")})")
    end
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 4
    @records.each do |item|
      item = [
              item.name,
              '<div class="text-center">'+item.programs_name+"</div>",
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
    self.search(q).limit(50).map {|model| {:id => model.id, :text => model.name} }
  end
  
  def json_encode_course_type_ids_names
    json = course_types.map {|t| {id: t.id.to_s, text: t.short_name}}
    json.to_json
  end
  
  def programs_name
    course_types.map(&:short_name).join(", ")
  end
  
end
