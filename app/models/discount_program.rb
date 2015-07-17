class DiscountProgram < ActiveRecord::Base
  include PgSearch
  
  validates :name, :presence => true
  
  belongs_to :user
  
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
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "0"
        order = "discount_programs.name"
      when "2"
        order = "discount_programs.rate"
      when "3"
        order = "discount_programs.start_at"
      when "4"
        order = "discount_programs.end_at"
      else
        order = "discount_programs.start_at"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "discount_programs.start_at"
    end
    
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 6
    @records.each do |item|
      item = [
              item.name,
              item.description,
              '<div class="text-center">'+item.rate.to_s+" (%)</div>",
              '<div class="text-center">'+item.start_at.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-center">'+item.end_at.strftime("%d-%b-%Y")+"</div>",              
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
end
