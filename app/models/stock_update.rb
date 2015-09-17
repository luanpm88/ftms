class StockUpdate < ActiveRecord::Base
  include PgSearch
  
  belongs_to :book
  belongs_to :user
  
  pg_search_scope :search,
                  against: [:note, :destination],
                  associated_against: {
                    book: [:name],
                    user: [:name]
                  },
                  using: {
                      tsearch: {
                        dictionary: 'english',
                        any_word: true,
                        prefix: true
                      }
                  }
  
  def self.update_stocks(params,user)
    params[:stock_updates].each do |row|
      if row[1]["book_id"].present? && row[1]["quantity"].present?
        update = StockUpdate.new
        update.type_name = params["type_name"]
        update.destination = params["destination"]
        update.note = params["note"]
        update.book_id = row[1]["book_id"]
        update.quantity = row[1]["quantity"]
        update.user = user
        update.created_date = Time.now
        
        update.save
      end
    end
  end
  
  def self.datatable(params, user)
    
    @records = self.all
    
    if params["type_name"].present?
      @records = @records.where(type_name: params["type_name"])
    end
    
    if params["created_from"].present?      
      @records = @records.where("created_date >= ?", params["created_from"].to_date)
    end
    if params["created_to"].present?      
      @records = @records.where("created_date <= ?", params["created_to"].to_date)
    end
    
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when false
      else
        order = "stock_updates.created_date"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "stock_updates.created_date"
    end
    
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 5
    @records.each do |item|
      item = [
              item.book.cover_link,
              item.book.book_link,
              '<div class="text-center">'+item.type_name+"</div>",
              '<div class="text-center">'+item.quantity.to_s+"</div>",
              '<div class="text-center">'+item.created_date.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-center">'+item.user.staff_col+"</div>",
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
  
  def self.status_options
    [
      ["All",""],
      ["Out Of Stock","out_of_stock"],
    ]
  end

  
end
