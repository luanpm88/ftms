class BooksContact < ActiveRecord::Base
  include PgSearch
  
  belongs_to :contact
  belongs_to :book
  
  
  belongs_to :course_register
  belongs_to :discount_program
  
  has_many :books_contacts
  has_many :payment_record_details
  
  after_create :update_statuses
  before_destroy :remove_delivery_details
  
  def remove_delivery_details
    delivery_details.destroy_all
  end
  
  #def volumns
  #  b_ids = self.volumn_ids.split("][").map {|s| s.gsub("[","").gsub("]","") }
  #  return Book.where(id: b_ids)
  #end
  
  #pg_search_scope :search,
  #      against: [],
  #      associated_against: {
  #                  contact: [:name],
  #                  book: [:name]
  #                },
  #      using: {
  #        tsearch: {
  #          dictionary: 'english',
  #          any_word: true,
  #          prefix: true
  #        }
  #      }
  
  def no_price?
    price.to_f == -1
  end
  
  def price=(new)
    self[:price] = new.to_s.gsub(/\,/, '')
  end
  def discount=(new)
    self[:discount] = new.to_s.gsub(/\,/, '')
  end
  def money=(new)
    self[:money] = new.to_s.gsub(/\,/, '')
  end
  
  def self.all_delivery_waiting
    self.includes(:book, :course_register).where(course_registers: {cache_delivery_status: "not_delivered"}).order("books.name")
  end
  
  def total
    if price != -1
      return price*quantity - discount.to_f - discount_program_amount - money.to_f
    else
      return no_price_payment_record_detail.nil? ? 0 : no_price_payment_record_detail.total.to_f
    end
  end
  
  def no_price_payment_record_detail
    payment_record_details.includes(:payment_record).where(payment_records: {status: 1}).first
  end
  
  def no_price?
    #price == -1    
    if price == -1
      # find total in payment record
      no_price_payment_record_detail.nil? ? true : false
    else
      return false
    end
  end
  
  def paid?
    paid_amount == total && !no_price?
  end
  
  def discount_program_amount_old
    return 0.00 if discount_program.nil?
    
    return discount_program.type_name == "percent" ? (discount_program.rate/100)*price : discount_program.rate
  end
  
  def discount_program_amount
    result = 0.00    
    all_discount_programs.each do |row|
      if row["id"].present?
        dp = DiscountProgram.find(row["id"])
        result += dp.type_name == "percent" ? (dp.rate/100)*price : dp.rate
      end
    end
    
    return result
  end
  
  def all_discount_programs
    discount_programs.nil? ? [] : JSON.parse(discount_programs)
  end
  
  def remain
    quantity - delivered_count
  end
  
  def max_delivery
    if remain > book.stock
      book.stock > 0 ? book.stock : 0
    else
      remain
    end
  end
  
  def deliveries
    course_register.all_deliveries.joins(:delivery_details)
                              .where(delivery_details: {book_id: self.book_id})
  end
  
  def delivery_details
    DeliveryDetail.where(delivery_id: deliveries.map(&:id)).where(book_id: self.book_id)
  end
  
  def delivered_count
    return delivery_details.sum(:quantity)
  end
  
  def delivered?
    remain <= 0
  end
  
  def paid_amount(from_date=nil, to_date=nil)
    records = course_register.all_payment_records
    
    total = 0.00
    records.each do |p|
      prds = p.payment_record_details.where(books_contact_id: self.id)
      if from_date.present? && to_date.present?
        prds = prds.includes(:payment_record)
                    .where("payment_records.payment_date >= ? AND payment_records.payment_date >= ? ", from_date.beginning_of_day, to_date.end_of_day)
      end
      
      prds.each do |prd|
        total += prd.real_amount
      end
    end
    return total
  end
  
  def remain_amount(from_date=nil, to_date=nil)
    total - paid_amount(from_date, to_date)
  end
  
  def self.all_to_be_ordered(book_id=nil)
    result = self.joins(:book, :course_register, :contact).where("course_registers.parent_id IS NULL").where("course_registers.status LIKE ?", "%[active]%")
    result = result.where(book_id: book_id) if book_id.present?
    
    return result
  end
  
  def self.to_be_delivered_count(book_id=nil)
    count = 0
    self.all_to_be_ordered(book_id).each do |bc|
      count += bc.remain
    end
    return count
  end
  
  def self.to_be_ordered_count(book_id=nil)
    self.all_to_be_ordered(book_id).sum(:quantity)
  end
  
  def self.to_be_imported_count(book_id=nil)
    result = self.to_be_delivered_count(book_id) - Book.find(book_id).stock
    result = 0 if result < 0
    
    return result
  end
  
  def self.filter(params, user)
    @records = self.all_to_be_ordered
    
    if params["course_types"].present?
      @records = @records.includes(:book)
                          .where(books: {course_type_id: params["course_types"].split(",")})
    end
    
    if params["subjects"].present?
      @records = @records.includes(:book => :subject)
                          .where(subjects: {id: params["subjects"].split(",")})
    end
    
    if params["student"].present?
      @records = @records.where(:contact_id => params["student"])
    end
    
    if params["delivery_statuses"].present?
      @records = @records.where(cache_delivery_status: params["delivery_statuses"])
    end
    
    if params["books"].present?
      @records = @records.where(book_id: params["books"].split(","))
    end
    
    if params[:stock_types].present?
      @records = @records.where(books: {stock_type_id: params[:stock_types]})
    end
    
    if params[:courses].present?
      @records = @records.includes(:course_register => :contacts_courses).where(contacts_courses: {course_id: params[:courses].split(",")})
    end
    
    if params["upfront"] == "true"
      @records = @records.where(upfront: params["upfront"])
    else
      if params["upfront"] == "false"
        @records = @records.where(upfront: params["upfront"])
      end

      if params["intake_year"].present? && params["intake_month"].present?
        @records = @records.where("EXTRACT(YEAR FROM books_contacts.intake) = ? AND EXTRACT(MONTH FROM books_contacts.intake) = ? ", params["intake_year"], params["intake_month"])
      elsif params["intake_year"].present?
        @records = @records.where("EXTRACT(YEAR FROM books_contacts.intake) = ? ", params["intake_year"])
      elsif params["intake_month"].present?
        @records = @records.where("EXTRACT(MONTH FROM books_contacts.intake) = ? ", params["intake_month"])
      end
    end
    
    @records = @records.where("books.valid_from <= ?", params[:valid_on].to_datetime.beginning_of_day) if params[:valid_on].present?
    @records = @records.where("books.valid_to >= ?", params[:valid_on].to_datetime.end_of_day) if params[:valid_on].present?
    
    return @records
  end
  
  def self.datatable(params, user)
    @records = self.filter(params, user)
    
    @records = @records.joins(:course_register, :book => [:course_type, :subject, :stock_type])
                        .where("course_registers.status IS NOT NULL AND course_registers.status LIKE ?", "%[active]%")
    
    if !params["search"]["value"].empty?
      @records = @records.includes(:contact, :book => [:course_type, :subject, :stock_type])
      q = "%#{params["search"]["value"].downcase}%"
      @records = @records.where("LOWER(contacts.cache_search) LIKE ? OR LOWER(contacts.name) LIKE ? OR LOWER(books.name) LIKE ? OR LOWER(stock_types.name) LIKE ? OR LOWER(course_types.short_name) LIKE ? OR LOWER(subjects.name) LIKE ?",q,q,q,q,q,q)
    end
    
    
    order = "contacts.name, course_types.short_name, subjects.name, stock_types.display_order, books.created_at"
    #if !params["order"].nil?
    #  case params["order"]["0"]["column"]
    #  when "1"
    #    order = "contacts.name"
    #  else
    #    order = "books_contacts.created_at"
    #  end
    #  order += " "+params["order"]["0"]["dir"]
    #end
    
    @records = @records.order(order) # if !order.nil? && !params["search"].present?
    
    
    ## STATISTICS
    #counting = []
    #course_types = CourseType.where(id: Book.where(id: @records.map(&:book_id)).map(&:course_type_id)).order(:short_name)
    #course_types.each do |ct|
    #  row = {}
    #  row[:course_type] = ct
    #  row[:count] = @records.joins(:book => :course_type).where(course_types: {id: ct.id})
    #  
    #  counting << row
    #end
    
    
    total = @records.count
    @records = @records.limit(params[:length]).offset(params["start"])
    data = []
    
    actions_col = 7
    @records.each do |item|      
      item = [
              "<div class=\"checkbox check-default\"><input name=\"ids[]\" id=\"checkbox#{item.id}\" type=\"checkbox\" value=\"#{item.id}\"><label for=\"checkbox#{item.id}\"></label></div>",
              item.contact.contact_link,
              item.book.display_name+"<div class=\"nowrap valid_time\">#{item.display_valid_time}</div>".html_safe,
              '<div class="text-center">'+ item.delivered_count.to_s + "/" + item.quantity.to_s+"</div>",
              '<div class="text-center">'+ item.display_upfront+"</div>",
              '<div class="text-center">'+ item.display_delivery_status+"</div>",
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

  def display_valid_time
    upfront ? "" : book.display_valid_time
  end
  
  def display_delivery_status    
    if delivered?
      return "<a class=\"check-radio ajax-check-radioz\" title=\"#{display_deliveries}\" href=\"#c\"><i class=\"#{delivered?.to_s} icon-check#{delivered? ? "" : "-empty"}\"></i></a>"
    else
      return "<div class=\"nowrap check-radio\">"+ActionController::Base.helpers.link_to("<i class=\"#{delivered?.to_s} icon-check#{delivered? ? "" : "-empty"}\"></i>".html_safe, {controller: "deliveries", action: "new", course_register_id: self.course_register_id, tab_page: 1}, title: "Deliver Stock: #{self.contact.display_name}", title: 'Materials Delivery', class: "tab_page")+"</div>"
    end
  end
  
  def display_deliveries
    str = []
    Delivery.where(id: BooksContact.find(self.id).delivery_details.map(&:delivery_id)).each do |d|
      str << "[Delivered #{d.delivery_details.where(book_id: self.book_id).sum(:quantity)} stock(s); by #{d.user.name}; on #{d.delivery_date.strftime("%Y-%b-%d")}]"
    end
    return str.join("")
  end

  def delivery_status
    delivered? ? "delivered" : "not_delivered"
  end

  def update_statuses
    # delivery
    self.update_attribute(:cache_delivery_status, self.delivery_status)
  end

  def all_deliveries
    course_register.all_deliveries.includes(:delivery_details).where(delivery_details: {book_id: book_id})
  end

  def all_payment_records
    course_register.all_payment_records.includes(:payment_record_details).where(payment_record_details: {books_contact_id: self.id})
  end

  def display_upfront(link=true)
    if upfront
      # select_tag = ActionController::Base.helpers.select_tag('books[]', ActionController::Base.helpers.options_for_select(Book.active_books.where(course_type_id: book.course_type_id, subject_id: book.subject_id).collect{ |u| [u.display_name+u.display_valid_time, u.id] }), class: "modern_select bc-upfront-select width100")
      "<span class=\"upfront-box\"><a class=\"check-radio ajax-uncheck-book-upfront\" rel=\"#{self.id.to_s}\" href=\"#c\"><i class=\"icon-check\"></i></a> Upfront<div style=\"display:none\" class=\"select-bc-box\"></div></span>"
    else
      if delivered?
        "<a class=\"check-radio ajax-check-book-upfrontz\" href=\"#c\"><i class=\"icon-check-empty\"></i></a> Upfront"
      else
        "<a class=\"check-radio ajax-check-book-upfront\" bc_id=\"#{self.id.to_s}\" valid_time='#{self.book.display_valid_time}' rel=\"#{self.id.to_s}\" href=\"#c\"><i class=\"icon-check-empty\"></i></a> Upfront"
      end     
    end    
  end

  #def display_delivery_status    
  #  if delivered?
  #    return "<a class=\"check-radio ajax-check-radioz\" href=\"#c\"><i class=\"#{delivered?.to_s} icon-check#{delivered? ? "" : "-empty"}\"></i></a>"
  #  else
  #    return "<div class=\"nowrap check-radio\">"+ActionController::Base.helpers.link_to("<i class=\"#{delivered?.to_s} icon-check#{delivered? ? "" : "-empty"}\"></i>".html_safe, {controller: "deliveries", action: "new", course_register_id: self.course_register_id, tab_page: 1}, title: "Deliver Stock: #{self.contact.display_name}", title: 'Materials Delivery', class: "tab_page")+"</div>"
  #  end
  #end

  def upfont_title
    upfront ? "Upfront-" : ""
  end

  def display_delivery_status    
    if delivered?
      return "<div  title=\"\" class=\"nowrap check-radio\">"+ActionController::Base.helpers.link_to("<i class=\"#{delivered?.to_s} icon-check#{delivered? ? "" : "-empty"}\"></i>".html_safe, {controller: "books_contacts", action: "remove", id: self.id, tab_page: 1}, title: "Deliver Stock: #{self.contact.display_name}", title: "Remove Delivery #{display_deliveries}", class: "approve_link")+"</div> (#{delivered_count.to_s}/#{quantity.to_s}) delivered?"
    else
      if !self.upfront
        return "<div class=\"nowrap check-radio\">"+ActionController::Base.helpers.link_to("<i class=\"#{delivered?.to_s} icon-check#{delivered? ? "" : "-empty"}\"></i>".html_safe, {controller: "deliveries", action: "new", course_register_id: self.course_register_id, tab_page: 1}, title: "Deliver Stock: #{self.contact.display_name}", title: 'Materials Delivery', class: "tab_page")+"</div> (#{delivered_count.to_s}/#{quantity.to_s}) delivered?"
      else
        return "<div class=\"nowrap check-radio\">"+ActionController::Base.helpers.link_to("<i class=\"#{delivered?.to_s} icon-check#{delivered? ? "" : "-empty"}\"></i>".html_safe, "#", title: "Deliver Stock: #{self.contact.display_name}")+"</div> (#{delivered_count.to_s}/#{quantity.to_s}) delivered?"
      end
    end
  end

end
