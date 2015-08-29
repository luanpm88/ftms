class PaymentRecord < ActiveRecord::Base
  belongs_to :bank_account
  belongs_to :course_register
  belongs_to :user
  belongs_to :bank_account
  belongs_to :contact
  
  has_many :payment_record_details
  
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
     @records = self.where(status: 1)
     
    if params["students"].present?
      @records = @records.joins(:course_register)
      @records = @records.where("course_registers.contact_id IN (#{params["students"]})")
    end
    
    if params["from_date"].present?
      @records = @records.where("payment_records.payment_date >= ?", params["from_date"].to_datetime.beginning_of_day)
    end
    if params["to_date"].present?
      @records = @records.where("payment_records.payment_date <= ?", params["to_date"].to_datetime.end_of_day)
    end
    
    if params["account_manager"].present?
      @records = @records.joins(:course_register => :contact)
      @records = @records.where("contacts.account_manager_id = ?", params["account_manager"])
    end
    
    if params["bank_account"].present?
      @records = @records.where("payment_records.bank_account_id = ?", params["bank_account"])
    end
    
    if params["courses"].present?
      @records = @records.joins(:course_register => :contacts_courses)
      @records = @records.where("contacts_courses.course_id = ?", params["courses"])
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
      when "4"
        order = "payment_records.payment_date"
      else
        order = "payment_records.payment_date"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "payment_records.payment_date DESC, payment_records.created_at DESC"
    end    
    @records = @records.order(order) if !order.nil?    
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 8
    @records.each do |item|
      item = [
              item.course_register.contact.display_name,
              '<div class="text-left">'+item.course_register.course_list(false)+"</div>",
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.course_register.total)+"</div>",
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.total)+'</div>',
              '<div class="text-center">'+item.payment_date.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-center">'+item.bank_account.name+"</div>",
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.course_register.remain_amount(item.payment_date))+"</div>",
              '<div class="text-center">'+item.course_register.contact.account_manager.staff_col+"</div>",
              ""
              #'<div class="text-right">'+ApplicationController.helpers.format_price(item.amount)+"</div>",
              #'<div class="text-center">'+item.payment_date.strftime("%d-%b-%Y")+"</div>",
              #'<div class="text-left">'+item.note+"</div>",
              ##'<div class="text-center">'+item.course_register.display_payment_status+"</div>",
              #'<div class="text-center">'+item.course_register.course_register_link+"</div>",
              #'<div class="text-right">'+ApplicationController.helpers.format_price(item.course_register.remain_amount)+"</div>",
              #
              #
              #
              #'<div class="text-center">'+item.course_register.user.staff_col+"</div>",  
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
  
  
  
  def trash
    self.update_attribute(:status, 0)
  end
  
  def update_payment_record_details(params)
    params.each do |row|
      cc = ContactsCourse.find(row[0])
      if cc.present? && row[1]["amount"].present?
        pd = self.payment_record_details.new
        pd.amount = row[1]["amount"]
        pd.contacts_course_id = row[0]
      end
    end

  end
  
  def update_stock_payment_record_details(params)
    params.each do |row|
      cc = ContactsCourse.find(row[0])
      if cc.present? && row[1]["amount"].present?
        pd = self.payment_record_details.new
        pd.amount = row[1]["amount"]
        pd.books_contact_id = row[0]
      end
    end

  end
  
  def total
    payment_record_details.sum(:amount)
  end
  
end
