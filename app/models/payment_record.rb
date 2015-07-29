class PaymentRecord < ActiveRecord::Base
  belongs_to :bank_account
  belongs_to :course_register
  belongs_to :user
  
  include PgSearch
  
  pg_search_scope :search,
                  against: [:note],
                  using: {
                      tsearch: {
                        dictionary: 'english',
                        any_word: true,
                        prefix: true
                      }
                  }
  
  after_save :update_statuses
  
  def update_statuses
    course_register.update_statuses
  end
  
  def self.filter(params, user)
     @records = self.all
     
     if params["students"].present?
      @records = @records.joins(:course_register)
      @records = @records.where("course_registers.contact_id IN (#{params["students"]})")
    end
     
     return @records
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = self.filter(params, user)
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "0"
        order = "payment_records.payment_date"
      when "2"
        order = "payment_records.payment_date"
      else
        order = "payment_records.payment_date"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "payment_records.payment_date"
    end    
    @records = @records.order(order) if !order.nil?    
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 7
    @records.each do |item|
      item = [
              item.course_register.contact.display_name,
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.amount)+"</div>",
              '<div class="text-center">'+item.payment_date.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-left">'+item.note+"</div>",
              #'<div class="text-center">'+item.course_register.display_payment_status+"</div>",
              '<div class="text-center">'+item.course_register.course_register_link+"</div>",
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.course_register.remain_amount)+"</div>",
              
              
              
              '<div class="text-center">'+item.course_register.user.staff_col+"</div>",  
              ""
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
  
  def amount=(new)
    self[:amount] = new.to_s.gsub(/\,/, '')
  end
end
