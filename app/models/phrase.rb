class Phrase < ActiveRecord::Base
  include PgSearch
  validates :name, :presence => true, :uniqueness => true
  
  belongs_to :user
  
  has_and_belongs_to_many :subjects
  
  has_and_belongs_to_many :courses
  
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
        order = "phrases.name"
      when "3"
        order = "phrases.created_at"
      else
        order = "phrases.name"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "phrases.name"
    end
    
    @records = @records.order(order) if !order.nil?
    
    if params["subjects"].present?
      @records = @records.joins(:subjects)
      @records = @records.where("subjects.id IN (#{params["subjects"].join(",")})")
    end
    
    if params["course_types"].present?
      
      subject_ids = Subject.joins(:course_types).where(course_types: {id: params["course_types"]}).map(&:id)
      
      @records = @records.joins(:subjects)
      @records = @records.where("subjects.id IN (#{subject_ids.join(",")})")
    end
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 5
    @records.each do |item|
      item = [
              item.name,
              '<div class="text-center">'+item.course_types_name+"</div>",
              '<div class="text-center">'+item.subjecs_name+"</div>",
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
  
  def subjecs_name
    subjects.map(&:name).join(", ")
  end
  
  def course_types_name
    CourseType.where(id: CourseTypesSubject.where(subject_id: subjects.map(&:id)).map(&:course_type_id)).map(&:short_name).join(", ")
  end
  
  def json_encode_subjects_ids_names
    json = subjects.map {|t| {id: t.id.to_s, text: t.name}}
    json.to_json
  end
  
  def self.full_text_search(q)
    self.search(q).limit(50).map {|model| {:id => model.id, :text => model.name} }
  end
  
  def phrase_link
    ActionController::Base.helpers.link_to(self.name, {controller: "phrases", action: "edit", id: self.id, tab_page: 1}, title: self.name, class: "tab_page")
  end
end
