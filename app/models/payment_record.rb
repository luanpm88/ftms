class PaymentRecord < ActiveRecord::Base
  belongs_to :bank_account
  belongs_to :course_register
  belongs_to :user
  belongs_to :bank_account
  belongs_to :company, class_name: "Contact"
  
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
    if !course_register.nil?
      course_register.update_statuses
      course_register.contacts_courses.each do |cc|
        cc.update_statuses
      end
    end      
  end
  
  def self.filter(params, user)
     @records = self.where(status: 1)
     
    if params["students"].present?
      @records = @records.joins(:course_register)
      @records = @records.where("course_registers.contact_id IN (#{params["students"]})")
    end
    
    if params["company"].present?
      @records = @records.where(company_id: params["company"])
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
    
    # role
    if !user.has_role?("manager") && !user.has_role?("admin") && !user.has_role?("accountant")
      @records = @records.joins(:course_register => :contact)
                          .where("contacts.account_manager_id = ?", user.id)
    end
    
     
     return @records
  end
  
  def self.datatable(params, user)
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
              item.contact.display_name,
              '<div class="text-left">'+item.description+"</div>",
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.ordered_total)+"</div>",
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.total)+'</div>',
              '<div class="text-center">'+item.payment_date.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-center">'+item.bank_account.name+"</div>",
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.remain)+"</div>",
              '<div class="text-center">'+item.contact.staff_col+"</div>",
              ""
              #'<div class="text-right">'+ApplicationController.helpers.format_price(item.amount)+"</div>",
              #'<div class="text-center">'+item.payment_date.strftime("%d-%b-%Y")+"</div>",
              #'<div class="text-left">'+item.note+"</div>",
              ##'<div class="text-center">'+item.course_register.display_payment_status+"</div>",
              #'<div class="text-center">'+item.course_register.course_register_link+"</div>",
              #'<div class="text-right">'+ApplicationController.helpers.format_price(item.course_register.remain_amount)+"</div>",
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
  
  def contact
    company.nil? ? course_register.contact : company
  end
  
  def description
    company.nil? ? course_register.course_list(false) : ""
  end
  
  def ordered_total
    company.nil? ? course_register.total : amount
  end
  
  def remain
    if company.nil?
      return course_register.remain_amount(self.payment_date)
    else
      amount - total
    end
  end
  
  
  def self.datatable_payment_list(params, user)
    @records = ContactsCourse.joins(:course_register, :contact).where("course_registers.parent_id IS NULL").where("course_registers.status LIKE ?", "%[active]%")
    
    course_ids = nil
    if params["intake_year"].present? && params["intake_month"].present?
      @records = Course.where("EXTRACT(YEAR FROM courses.intake) = ? AND EXTRACT(MONTH FROM courses.intake) = ? ", params["intake_year"], params["intake_month"]).map(&:id)
    elsif params["intake_year"].present?
      course_ids = Course.where("EXTRACT(YEAR FROM courses.intake) = ? ", params["intake_year"]).map(&:id)      
    elsif params["intake_month"].present?
      course_ids = Course.where("EXTRACT(MONTH FROM courses.intake) = ? ", params["intake_month"]).map(&:id)
    end    
    @records = @records.where(course_id: course_ids) if !course_ids.nil?
    
    if params["upfront"].present?
      @records = @records.includes(:course).where(courses: {upfront: params["upfront"]})
    end
    
    if params["course_types"].present?
      @records = @records.joins(:course)
                          .where(courses: {course_type_id: params["course_types"].split(",")})
    end
    
    if params["subjects"].present?
      @records = @records.joins(:course)
                          .where(courses: {subject_id: params["subjects"]})
    end
    
    if params["student"].present?
      @records = @records.where(:contact_id => params["student"])
    end
    
    if params["payment_statuses"].present?
      @records = @records.where("contacts_courses.cache_payment_status LIKE ?", "%"+params["payment_statuses"]+"%")
    end
    
    if params["company"].present?
      @records = @records.includes(:course_register).where(course_registers: {payment_type: "company-sponsored", sponsored_company_id: params["company"]})
    end
    
    
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "contacts.name"
      else
        order = "contacts_courses.created_at"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "contacts_courses.created_at DESC"
    end
    @records = @records.order(order) if !order.nil?    
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 6
    @records.each do |item|
      item = [
              "<div class=\"checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
              item.contact.contact_link,
              '<div class="text-left">'+item.course.display_name+"</div>",
              '<div class="text-right"><label class="col_label top0">Total:</label>'+ApplicationController.helpers.format_price(item.total)+"<label class=\"col_label top0\">Paid:</label>"+ApplicationController.helpers.format_price(item.paid)+"<label class=\"col_label top0\">Receivable:</label>"+ApplicationController.helpers.format_price(item.remain)+"</div>",
              '<div class="text-center">'+item.display_payment_status+item.course_register.display_payment+"</div>",
              '<div class="text-center">'+ item.course_register.course_register_link+"</div>", 
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
  
  
  
  def trash
    self.update_attribute(:status, 0)
  end
  
  def update_payment_record_details(params)
    params.each do |row|
      cc = ContactsCourse.find(row[0])
      if cc.present? && (row[1]["amount"].present? || row[1]["total"].present?)
        pd = self.payment_record_details.new
        pd.amount = row[1]["amount"]
        pd.contacts_course_id = row[0]
        if cc.no_price?
          pd.total = row[1]["total"]
        end        
      end
    end

  end
  
  def update_company_payment_record_details(params)
    params.each do |row|
      if row[1]["amount"].present? && row[1]["course_type_id"].present?
        pd = self.payment_record_details.new
        pd.amount = row[1]["amount"]
        pd.course_type_id = row[1]["course_type_id"]       
      end
    end

  end
  
  def update_stock_payment_record_details(params)
    params.each do |row|
      bc = BooksContact.find(row[0])
      if bc.present? && (row[1]["amount"].present? || row[1]["total"].present?)
        pd = self.payment_record_details.new
        pd.amount = row[1]["amount"]
        pd.books_contact_id = row[0]
        if bc.no_price?
          pd.total = row[1]["total"]
        end
      end
    end

  end
  
  def total
    payment_record_details.sum(:amount)
  end
  
  def amount=(new)
    self[:amount] = new.to_s.gsub(/\,/, '')
  end
  
  def course_registers
    return [] if self.course_register_ids.nil?
    cr_ids = self.course_register_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
    return CourseRegister.where(id: cr_ids)
  end
  
end
