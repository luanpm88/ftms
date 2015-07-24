class CourseRegister < ActiveRecord::Base
  belongs_to :user
  
  has_many :contacts_courses, class_name: "ContactsCourse", foreign_key: "course_register_id", :dependent => :destroy
  has_many :books_contacts, class_name: "BooksContact", foreign_key: "course_register_id", :dependent => :destroy
  
  belongs_to :contact
  belongs_to :discount_program
  belongs_to :bank_account
  
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
        cc.contact_id = contact.id
        cc.volumn_ids = "["+row[1]["volumn_ids"].join("][")+"]"        
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
      order = "course_registers.created_date"
    end
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 7
    @records.each do |item|
      item = [
              item.contact.contact_link,
              item.course_list,
              item.book_list,
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.total)+"</div>",
              '<div class="text-center">'+item.payment+"</div>",
              '<div class="text-center">'+item.created_date.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-center">'+item.user.staff_col+"</div>",
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
      order = "course_registers.created_date"
    end
    @records = @records.order(order) if !order.nil?
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    
    data = []
    
    actions_col = 7
    @records.each do |item|
      item = [
              item.contact.contact_link,
              item.course_list,
              item.book_list,
              '<div class="text-right">'+ApplicationController.helpers.format_price(item.total)+"</div>",
              '<div class="text-center">'+item.payment+"</div>",
              '<div class="text-center">'+item.created_date.strftime("%d-%b-%Y")+"</div>",
              '<div class="text-center">'+item.user.staff_col+"</div>",
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
  
  def course_list
    arr = []
    courses.each do |row|
      arr << "<div><strong>"+row[:course].display_name+"</strong></div>"
      arr << "<div class=\"courses_phrases_list\">"+Course.render_courses_phrase_list(row[:courses_phrases])+"</div>"
      
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
      arr << row[:volumns].map(&:name).join(", ")
    end
    
    return arr.join("")
  end
  
  def books
    arr = []
    books_contacts.each do |bc|
      item = {}
      item[:book] = bc.book
      item[:volumns] = bc.volumns
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
    price - discount.to_f - discount_program_amount
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
  
end
