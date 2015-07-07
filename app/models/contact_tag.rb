class ContactTag < ActiveRecord::Base
  include PgSearch
  validates :name, presence: true, :uniqueness => true
  
  has_and_belongs_to_many :contacts
  
  pg_search_scope :search,
                against: [:name, :description],                
                using: {
                  tsearch: {
                    dictionary: 'english',
                    any_word: true,
                    prefix: true
                  }
                }
  
  def self.full_text_search(q)    
    self.search(q).limit(50).map {|model| {:id => model.id, :text => model.name} }
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = self.all
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "0"
        order = "contact_tags.name"      
      else
        order = "contact_tags.name"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "contact_tags.name"
    end    
    @records = @records.order(order) if !order.nil?
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 3
    @records.each do |item|
      item = [
              '<div class="text-left nowrap">'+item.name+"</div>",
              '<div class="text-left">'+item.description+"</div>",
              '<div class="text-center">'+item.created_at.strftime("%d-%b-%Y")+"</div>",
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
end
