class BankAccount < ActiveRecord::Base
  validates :name, presence: true, :uniqueness => true
  validates :bank_name, presence: true
  validates :account_name, presence: true
  validates :account_number, presence: true
  validates :user_id, presence: true
  
  belongs_to :user
  
  include PgSearch
  
  pg_search_scope :search,
                  against: [:name, :bank_name, :account_name, :account_number],
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
        order = "bank_accounts.name"
      when "4"
        order = "bank_accounts.created_at"
      else
        order = "bank_accounts.name"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "bank_accounts.name"
    end
    
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 6
    @records.each do |item|
      item = [
              item.name,
              '<div class="text-left">'+item.bank_name+"</div>",
              '<div class="text-left">'+item.account_name+"</div>",
              '<div class="text-left">'+item.account_number+"</div>",
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
end
