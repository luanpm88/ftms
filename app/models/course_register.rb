class CourseRegister < ActiveRecord::Base
  belongs_to :user
  
  has_many :contacts_courses, class_name: "ContactsCourse", foreign_key: "course_register_id", :dependent => :destroy
  has_many :books_contacts, class_name: "BooksContact", foreign_key: "course_register_id", :dependent => :destroy
  
  belongs_to :contact
  belongs_to :discount_program
  belongs_to :bank_account
  
  
  
  has_many :deliveries, :dependent => :destroy
  
  has_many :payment_records, :dependent => :destroy
  
  has_one :last_payment_record, -> { order created_at: :desc }, class_name: 'PaymentRecord', foreign_key: "course_register_id"
  
  include PgSearch
  
  pg_search_scope :search,
                  against: [:mailing_address],
                  using: {
                      tsearch: {
                        dictionary: 'english',
                        any_word: true,
                        prefix: true
                      }
                  }
  
  after_create :update_statuses
  
  def all_deliveries
    deliveries.where(status: 1).order("delivery_date DESC, created_at DESC")
  end
  
  def all_payment_records
    payment_records.where(status: 1).order("payment_date DESC, created_at DESC")
  end
  
  def save_contacts_courses(cids)
    contact = self.contact
    
    cids.each do |row|
      if row[1]["course_id"].present?
        cc = contact.contacts_courses.new
        cc.course_id = row[1]["course_id"]
        cc.course_register_id = self.id
        cc.courses_phrase_ids = "["+row[1]["courses_phrase_ids"].join("][")+"]"
        cc.upfront = row[1]["upfront"]
        cc.price = row[1]["price"]
        cc.discount_program_id = row[1]["discount_program_id"]
        cc.discount = row[1]["discount"]
        cc.save if ContactsCourse.where(contact_id: cc.contact_id, course_id: cc.course_id).empty?
      end
    end
    
    #change contact type when add course
    contact.update_info
  end
  
  def update_contacts_courses(cids)
    contact = self.contact
    
    cids.each do |row|
      if row[1]["course_id"].present?
        cc = self.contacts_courses.new
        cc.course_id = row[1]["course_id"]
        cc.contact_id = contact.id
        cc.courses_phrase_ids = "["+row[1]["courses_phrase_ids"].join("][")+"]"
        cc.upfront = row[1]["upfront"]
        cc.price = row[1]["price"]
        cc.discount_program_id = row[1]["discount_program_id"]
        cc.discount = row[1]["discount"]
      end
    end

  end
  
  def update_books_contacts(cids)
    contact = self.contact    
    cids.each do |row|
      if row[1]["book_id"].present?
        cc = self.books_contacts.new
        cc.book_id = row[1]["book_id"]
        cc.quantity = row[1]["quantity"]
        cc.contact_id = contact.id
        cc.price = row[1]["price"]
        cc.discount_program_id = row[1]["discount_program_id"]
        cc.discount = row[1]["discount"]
      end
    end
  end
  
  def self.filter(params, user)
    @records = self.all
    
    if params["course_types"].present?
      course_ids = Course.where(course_type_id: params["course_types"]).map(&:id)
      @records = @records.joins(:contacts_courses => :course)
                          .where(courses: {id: course_ids})
    end
    
    if params["subjects"].present?
      course_ids = Course.where(subject_id: params["subjects"]).map(&:id)
      @records = @records.joins(:contacts_courses => :course)
                          .where(courses: {id: course_ids})
    end
    
    if params["student"].present?
      @records = @records.where(:contact_id => params["student"])
    end
    
    if params[:courses].present?
      @records = @records.joins(:contacts_courses => :course)
                          .where(courses: {id: params[:courses].split(",")})
    end
    
    if params["delivery_statuses"].present?
      @records = @records.where(cache_delivery_status: params["delivery_statuses"])
    end
    
    if params["payment_statuses"].present?
      @records = @records.where("cache_payment_status LIKE ?", "%"+params["payment_statuses"]+"%")
    end
    
    course_ids = nil
    if params["intake_year"].present? && params["intake_month"].present?
      course_ids = Course.where("EXTRACT(YEAR FROM courses.intake) = ? AND EXTRACT(MONTH FROM courses.intake) = ? ", params["intake_year"], params["intake_month"]).map(&:id)
    elsif params["intake_year"].present?
      course_ids = Course.where("EXTRACT(YEAR FROM courses.intake) = ? ", params["intake_year"]).map(&:id)
    elsif params["intake_month"].present?
      course_ids = Course.where("EXTRACT(MONTH FROM courses.intake) = ? ", params["intake_month"]).map(&:id)
    end
    
    @records = @records.joins(:contacts_courses => :course).where(courses: {id: course_ids}) if !course_ids.nil?
    
    @records = @records.search(params["search"]["value"]) if !params["search"]["value"].empty?
    
    return @records
  end
  
  def self.datatable(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @records = self.filter(params, user)
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "0"
        order = "course_registers.created_date"
      when "2"
        order = "course_registers.created_date"
      else
        order = "course_registers.created_date"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "course_registers.created_date DESC, course_registers.created_at DESC"
    end
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 8
    @records.each do |item|
      item = [
              item.contact.contact_link,
              item.course_list,
              item.book_list,
              '<div class="text-center">'+item.display_delivery_status+"</div>",
              '<div class="text-right"><label class="col_label top0">Total:</label>'+ApplicationController.helpers.format_price(item.total)+"<label class=\"col_label top0\">Paid:</label>"+ApplicationController.helpers.format_price(item.paid_amount)+"<label class=\"col_label top0\">Receivable:</label>"+ApplicationController.helpers.format_price(item.remain_amount)+"</div>",
              '<div class="text-center">'+item.display_payment_status+item.payment+"</div>",
              '<div class="text-center">'+item.created_date.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-center">'+item.contact.account_manager.staff_col+"</div>",
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
  
  def self.student_course_registers(params, user)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers    
    
    @student = Contact.find(params[:student])
    
    @records =  self.filter(params, user)
    
    @records = @records.where(contact_id: @student.id)
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "0"
        order = "course_registers.created_date"
      when "2"
        order = "course_registers.created_date"
      else
        order = "course_registers.created_date"
      end
      order += " "+params["order"]["0"]["dir"]
    else
      order = "course_registers.created_date DESC, course_registers.created_at DESC"
    end
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 8
    @records.each do |item|
      item = [
              item.contact.contact_link,
              item.course_list,
              item.book_list,
              '<div class="text-center">'+item.display_delivery_status+"</div>",
              '<div class="text-right"><label class="col_label top0">Total:</label>'+ApplicationController.helpers.format_price(item.total)+"<label class=\"col_label top0\">Paid:</label>"+ApplicationController.helpers.format_price(item.paid_amount)+"<label class=\"col_label top0\">Remain:</label>"+ApplicationController.helpers.format_price(item.remain_amount)+"</div>",
              '<div class="text-center">'+item.display_payment_status+item.payment+"</div>",
              '<div class="text-center">'+item.created_date.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-center">'+item.contact.account_manager.staff_col+"</div>",
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
  
  def course_list(phrase_list=true)
    arr = []
    courses.each do |row|
      arr << "<div><strong>"+row[:course].display_name+"</strong></div>"
      arr << "<div class=\"courses_phrases_list\">"+Course.render_courses_phrase_list(row[:courses_phrases])+"</div>" if phrase_list
      
    end
    
    return arr.join("")
  end
  
  def courses
    arr = []
    contacts_courses.each do |cc|
      item = {}
      item[:course] = cc.course
      item[:courses_phrases] = cc.courses_phrases
      arr << item
    end
    
    return arr
  end
  
  def book_list
    arr = []
    books.each do |row|
      arr << "<div><strong>"+row[:book].name+"</strong></div>"
      #arr << row[:volumns].map(&:name).join(", ")
    end
    
    return arr.join("")
  end
  
  def books
    arr = []
    books_contacts.each do |bc|
      item = {}
      item[:book] = bc.book
      #item[:volumns] = bc.volumns
      arr << item
    end    
    return arr
  end
  
  def course_total
    course = 0.00
    contacts_courses.each do |cc|
      course += cc.total
    end
    return course
  end
  
  def stock_total
    stock = 0.00
    books_contacts.each do |bc|
      stock += bc.total
    end
    
    return stock
  end
  
  def price
    return course_total + stock_total
  end
  
  def total
    price - discount.to_f - discount_program_amount - discount.to_f - transfer.to_f
  end
  
  def discount_program_amount
    return 0.00 if discount_program.nil?
    
    return discount_program.type_name == "percent" ? (discount_program.rate/100)*price : discount_program.rate
  end
  
  def payment
    str = ""
    if payment_type = "self-financed"
      str += "self-financed"
    else
      str + "company-sponsored"
    end
    
    str + "<div>#{bank_account.name}</div>"
    
    return str
  end
  
  def discount=(new)
    self[:discount] = new.to_s.gsub(/\,/, '')
  end
  
  
  def stock_count
    books_contacts.count
  end
  
  def display_delivery_status    
    return "" if books.count == 0
    
    if delivered?
      return "<a class=\"check-radio ajax-check-radioz\" href=\"#c\"><i class=\"#{delivered?.to_s} icon-check#{delivered? ? "" : "-empty"}\"></i></a>"
    else
      return "<div class=\"nowrap check-radio\">"+ActionController::Base.helpers.link_to("<i class=\"#{delivered?.to_s} icon-check#{delivered? ? "" : "-empty"}\"></i>".html_safe, {controller: "deliveries", action: "new", course_register_id: self.id, tab_page: 1}, title: "Deliver Stock: #{self.contact.display_name}", title: 'Materials Delivery', class: "tab_page")+"</div>"
    end

  end
  
  def delivery_info
    #if delivered?
    #  return "On"+delivery.delivery_date.strftime("%d-%b-%Y")+""
    #end    
  end
  
  def delivered?
    self.books_contacts.each do |bc|
      if !bc.delivered?
        return false
      end      
    end
    return true
  end
  
  def self.all_waiting_deliveries
    self.includes(:deliveries, :books_contacts).where(deliveries: {id: nil}).where.not(books_contacts: {id: nil})
  end
  
  def paid_amount(date=nil)
    records = all_payment_records
    if date.present?
      records = records.where("payment_date <= ?", date)
    end
    return records.sum(:amount)
  end
  
  def paid?
    paid_amount == total
  end
  
  def remain_amount(date=nil)
    total - paid_amount(date)
  end
  
  def payment_status
    str = []
    if paid?
      str << "fully_paid"
    else
      str << "receivable"
    end
    if out_of_date?    
      str << "chase_for_payment"
    end
    
    return str
  end
  
  def display_payment_status
    line = []
    payment_status.each do |s|
      line << "<div class=\"#{s} text-center\">#{s}</div>".html_safe
    end
    
    return line.join("")
  end
  
  def debt?
    return false if paid?
    
    return real_debt_date.nil? ? false : real_debt_date >= Time.now
  end
  
  def out_of_date?
    return false if paid?
    
    return real_debt_date.nil? ? false : real_debt_date < Time.now
  end
  
  def real_debt_date
    if !last_payment.nil?
      self.last_payment.debt_date
    else
      self.debt_date
    end
  end
  
  def last_payment
    all_payment_records.order("payment_date DESC, created_at DESC").first
  end
  
  def course_register_link
    ActionController::Base.helpers.link_to("<i class=\"icon icon-list-alt\"></i> Course Register [#{created_date.strftime("%d-%b-%Y")}]".html_safe, {controller: "course_registers", action: "show", id: self.id, tab_page: 1}, title: "Course Register Detail: #{self.contact.display_name} [#{created_date.strftime("%d-%b-%Y")}]", class: "tab_page")
  end
  
  def self.update_all_statuses
    self.all.each do |c|
      c.update_statuses
      c.save
    end
  end
  
  def update_statuses
    # delivery
    self.update_attribute(:cache_delivery_status, self.delivery_status)
    
    # payment
    self.update_attribute(:cache_payment_status, self.payment_status.join(","))
  end
  
  def delivery_status
    return "" if self.books.count == 0
    delivered? ? "delivered" : "not_delivered"
  end
  
end
